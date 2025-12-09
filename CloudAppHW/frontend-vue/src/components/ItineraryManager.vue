<!-- frontend-vue/src/components/ItineraryManager.vue -->
<script setup>
import { ref, onMounted, watch, computed } from 'vue';
import axios from 'axios';
import { showModal } from '../utils/modal.js';
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

// --- AI Suggestion (Firestore polling) ---
const aiStatus = ref('idle'); // idle | queued | ok | no_suggestion | error
const aiPollTimer = ref(null);
const aiLastFetchAt = ref(0);

function clearAiTimer() {
  if (aiPollTimer.value) {
    clearInterval(aiPollTimer.value);
    aiPollTimer.value = null;
  }
}

/** 讀一次 Firestore 裡的 AI 記錄（aiSuggestions/{id}） */
async function fetchAiSuggestionOnce(itineraryId) {
  try {
    const res = await axios.get(`${API_BASE_URL}/api/itineraries/${itineraryId}/ai`);
    const data = res.data || {};
    aiStatus.value = data.status || 'no_suggestion';
    // 寫回畫面用的欄位（你的 template 已經用 selectedItinerary.aiSuggestion）
    if (selectedItinerary.value && String(selectedItinerary.value.id) === String(itineraryId)) {
      selectedItinerary.value.aiSuggestion = data.suggestion || '';
    }
    aiLastFetchAt.value = Date.now();
    return { found: true, terminal: ['ok', 'no_suggestion', 'error'].includes(aiStatus.value) };
  } catch (err) {
    // 404 代表還沒寫入 → 當作 queued
    if (err?.response?.status === 404) {
      aiStatus.value = 'queued';
      return { found: false, terminal: false };
    }
    console.error('[AI] fetch error:', err?.message || err);
    aiStatus.value = 'error';
    return { found: false, terminal: true };
  }
}

/** 開始輪詢，直到拿到終局狀態 */
async function startAiPolling(itineraryId, { intervalMs = 2000, maxTries = 8 } = {}) {
  clearAiTimer();
  aiStatus.value = 'queued';
  // 先打一次
  let tries = 0;
  const first = await fetchAiSuggestionOnce(itineraryId);
  if (first.terminal) return;

  aiPollTimer.value = setInterval(async () => {
    tries++;
    const r = await fetchAiSuggestionOnce(itineraryId);
    if (r.terminal || tries >= maxTries) {
      clearAiTimer();
    }
  }, intervalMs);
}

// --- Format AI Text (Simple Markdown) ---
function formatAiText(text) {
  if (!text) return '';
  // Replace **text** with <strong>text</strong>
  // Escape HTML first to prevent XSS (basic)
  let safe = text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");

  // Bold
  safe = safe.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
  
  // Optional: Convert bullet points (lines starting with - or *)
  // safe = safe.replace(/^[*-] (.*)$/gm, '<li>$1</li>');
  
  return safe;
}

const props = defineProps({
  travellerEmail: {
    type: String,
    required: true
  },
  currentUserEmail: {
    type: String,
    required: true
  },
  refreshSignal: Number
});

const emit = defineEmits(['no-data']);

/* ---------------- base state ---------------- */
const rawItineraries = ref([]);
const userItineraries = ref([]);
const loading = ref(false);
const error = ref('');

const selectedItinerary = ref(null);
const isEditing = ref(false);
const editForm = ref({});
const editMessage = ref('');

/* view mode: 全部(true) or 只看該使用者(false) */
const showAll = ref(false);

/* 搜尋欄 */
const filterText = ref('');
const filterStart = ref('');
const filterEnd = ref('');

/* ---------------- computed: 是否在看自己 ---------------- */
const isViewingSelf = computed(() => {
  const a = (props.travellerEmail || '').toLowerCase();
  const b = (props.currentUserEmail || '').toLowerCase();
  return a && b && a === b;
});

/* ---------------- 預設顯示模式 ---------------- */
watch(
    [() => props.travellerEmail, () => props.currentUserEmail],
    () => {
      if (isViewingSelf.value) {
        showAll.value = true;
        filterText.value = '';
      } else {
        showAll.value = false;
        filterText.value = '';
      }
    },
    { immediate: true }
);

/* ---------------- 抓行程資料 ---------------- */
async function fetchItineraries() {
  error.value = '';
  loading.value = true;

  if (!props.travellerEmail) {
    loading.value = false;
    return;
  }

  try {
    const response = await axios.get(
        `${API_BASE_URL}/api/itineraries/by-email/${props.travellerEmail}`
    );

    rawItineraries.value = response.data || [];

    const who = (props.travellerEmail || '').toLowerCase();

    userItineraries.value = rawItineraries.value.filter(it => {
      return (it.traveller_email || '').toLowerCase() === who;
    });

    if (!isViewingSelf.value && userItineraries.value.length === 0) {
      emit('no-data');
    }

    const visibleIds = new Set(
        (showAll.value ? rawItineraries.value : userItineraries.value).map(it => it.id)
    );
    if (selectedItinerary.value && !visibleIds.has(selectedItinerary.value.id)) {
      selectedItinerary.value = null;
      isEditing.value = false;
    }
  } catch (e) {
    error.value = 'Unable to load trips. Check your Internet connection.';
    if (!isViewingSelf.value) {
      emit('no-data');
    }
  } finally {
    loading.value = false;
  }
}

watch(() => props.travellerEmail, (newEmail) => { if (newEmail) fetchItineraries(); }, { immediate: true });
watch(() => props.refreshSignal, () => { fetchItineraries(); });

/* ---------------- 產生要顯示的清單 ---------------- */
const displayBaseList = computed(() => (showAll.value ? rawItineraries.value : userItineraries.value));

/* ---------------- 搜尋 / 日期篩選後的清單 ---------------- */
const filteredItineraries = computed(() => {
  const text = filterText.value.trim().toLowerCase();
  const start = filterStart.value ? new Date(filterStart.value) : null;
  const end   = filterEnd.value   ? new Date(filterEnd.value)   : null;

  return displayBaseList.value.filter((it) => {
    const t = (it.title || '').toLowerCase();
    const d = (it.destination || '').toLowerCase();
    const s = (it.short_description || '').toLowerCase();
    const l = (it.detail_description || '').toLowerCase();
    const e = (it.traveller_email || '').toLowerCase();

    const matchText = !text || [t, d, s, l, e].some(v => v.includes(text));

    const itStart = it.start_date ? new Date(it.start_date) : null;
    const itEnd   = it.end_date   ? new Date(it.end_date)   : itStart;

    let matchDate = true;
    if (start && end) {
      matchDate = !(itEnd && itEnd < start) && !(itStart && itStart > end);
    } else if (start) {
      matchDate = !itEnd || itEnd >= start;
    } else if (end) {
      matchDate = !itStart || itStart <= end;
    }

    return matchText && matchDate;
  });
});

/* =======================================================
   LIKE SYSTEM
======================================================= */
const likeMap = ref({});
const likeCountMap = ref({});
const likeListVisible = ref(false);
const likeListUsers = ref([]);
const likeListTripId = ref(null);

async function loadLikeInfo(itineraryId) {
  if (!itineraryId) return;
  try {
    const countRes = await axios.get(`${API_BASE_URL}/api/itineraries/${itineraryId}/like/count`);
    likeCountMap.value[itineraryId] = countRes.data.count ?? 0;

    const listRes = await axios.get(`${API_BASE_URL}/api/itineraries/${itineraryId}/like/list`);
    const users = listRes.data.users || [];
    likeMap.value[itineraryId] = users.some(u => u.email === props.currentUserEmail);
  } catch (err) {
    console.error('Failed to load like info', err);
    if (likeCountMap.value[itineraryId] === undefined) likeCountMap.value[itineraryId] = 0;
    if (likeMap.value[itineraryId] === undefined) likeMap.value[itineraryId] = false;
  }
}

async function loadLikesForVisibleTrips() {
  const ids = filteredItineraries.value.map(it => it.id);
  await Promise.all(ids.map(id => loadLikeInfo(id)));
}

watch(filteredItineraries, () => { loadLikesForVisibleTrips(); });
watch(() => rawItineraries.value.length, () => { loadLikesForVisibleTrips(); });

async function toggleLike(itineraryId) {
  if (!props.currentUserEmail) {
    showModal({ title: 'Login Required', message: 'Please login first.', type: 'alert' });
    return;
  }
  try {
    const res = await axios.post(`${API_BASE_URL}/api/itineraries/${itineraryId}/like/toggle`);
    const likedNow = !!res.data.liked;
    likeMap.value[itineraryId] = likedNow;
    likeCountMap.value[itineraryId] = Math.max(0, (likeCountMap.value[itineraryId] || 0) + (likedNow ? 1 : -1));
  } catch (err) {
    console.error('Toggle like failed', err);
    showModal({ title: 'Error', message: 'Like failed.', type: 'alert' });
  }
}

async function showLikeList(itineraryId) {
  try {
    const res = await axios.get(`${API_BASE_URL}/api/itineraries/${itineraryId}/like/list`);
    likeListUsers.value = res.data.users || [];
    likeListTripId.value = itineraryId;
    likeListVisible.value = true;
  } catch (err) {
    console.error('Failed to load like list', err);
    showModal({ title: 'Error', message: 'Failed to load who liked this.', type: 'alert' });
  }
}

function closeLikeList() {
  likeListVisible.value = false;
  likeListTripId.value = null;
  likeListUsers.value = [];
}

/* ---------------- 查看詳細 ---------------- */
async function viewDetails(id) {
  error.value = '';
  editMessage.value = '';
  isEditing.value = false;

  try {
    const response = await axios.get(`${API_BASE_URL}/api/itineraries/detail/${id}`);
    const data = response.data;

    if (!showAll.value) {
      const who = (props.travellerEmail || '').toLowerCase();
      const ownerLower = (data.traveller_email || '').toLowerCase();
      if (ownerLower !== who) {
        selectedItinerary.value = null;
        editForm.value = {};
        error.value = 'You are not allowed to view this trip detail.';
        return;
      }
    }

    selectedItinerary.value = data;
    // 先清空舊的 AI 結果與狀態，避免顯示到上一次的內容
    selectedItinerary.value.aiSuggestion = '';
    aiStatus.value = 'idle';

    editForm.value = { ...data };

    await loadLikeInfo(id);
    await loadComments(id);

    // 🔔 啟動 AI 輪詢（讀 aiSuggestions/{id}）
    startAiPolling(id);

  } catch (e) {
    error.value = 'Unable to load trip detail.';
  }
}
/* ---------------- 編輯 / 儲存 / 刪除 ---------------- */
function startEdit() { isEditing.value = true; }
function cancelEdit() { isEditing.value = false; editForm.value = { ...selectedItinerary.value }; }

async function saveEdit() {
  editMessage.value = '';
  const data = editForm.value;

  if (data.short_description.length > 80) {
    editMessage.value = 'Short Description should not longer than 80 letters.';
    return;
  }

  try {
    // 不再需要 traveller_email 放 body，後端用 token 驗證擁有者
    await axios.put(`${API_BASE_URL}/api/itineraries/${data.id}`, {
      title: data.title,
      destination: data.destination,
      start_date: data.start_date,
      end_date: data.end_date,
      short_description: data.short_description,
      detail_description: data.detail_description
    });
    editMessage.value = 'Successfully updated';
    isEditing.value = false;
    await viewDetails(data.id);
    fetchItineraries();
  } catch (e) {
    editMessage.value = 'Update failed. Server error.';
  }
}

async function deleteItinerary() {
  if (!selectedItinerary.value) return;

  const currentId = selectedItinerary.value.id; // Capture ID
  const title = selectedItinerary.value.title;

  showModal({
    title: 'Delete Trip',
    message: `Delete trip "${title}" ?`,
    type: 'confirm',
    confirmText: 'Delete',
    onConfirm: async () => {
      try {
        await axios.delete(`${API_BASE_URL}/api/itineraries/${currentId}`);
        showModal({ title: 'Success', message: 'Deleted!', type: 'alert' });
        selectedItinerary.value = null;
        fetchItineraries();
      } catch (e) {
        showModal({ title: 'Error', message: 'Delete failed', type: 'alert' });
      }
    }
  });
}

/* ---------------- 切換顯示按鈕 ---------------- */
function viewOnlyThisUser() { showAll.value = false; filterText.value = ''; }
function viewAllTrips() { if (!isViewingSelf.value) return; showAll.value = true; filterText.value = ''; }

// ======================
// Comments (Firestore)
// ======================
const comments = ref([]);
const newCommentText = ref('');
const loadingComments = ref(false);
const postingComment = ref(false);

async function loadComments(itineraryId) {
  if (!itineraryId) return;
  loadingComments.value = true;
  try {
    const res = await axios.get(`${API_BASE_URL}/api/itineraries/${itineraryId}/comments`);
    comments.value = res.data.comments || [];
  } catch (err) {
    console.error('Failed to load comments', err);
    comments.value = [];
  } finally {
    loadingComments.value = false;
  }
}

async function submitComment() {
  if (!props.currentUserEmail) {
    showModal({ title: 'Login Required', message: 'Please login first.', type: 'alert' });
    return;
  }
  const text = newCommentText.value.trim();
  if (!text) {
    showModal({ title: 'Validation', message: 'Comment cannot be empty.', type: 'alert' });
    return;
  }
  if (!selectedItinerary.value) return;

  postingComment.value = true;
  try {
    await axios.post(`${API_BASE_URL}/api/itineraries/${selectedItinerary.value.id}/comments`, {
      text // 後端會從 token 取 email
    });
    newCommentText.value = '';
    await loadComments(selectedItinerary.value.id);
  } catch (err) {
    console.error('Failed to post comment', err);
    showModal({ title: 'Error', message: 'Failed to post comment.', type: 'alert' });
  } finally {
    postingComment.value = false;
  }
}

async function deleteComment(commentId, commentEmail) {
  if (commentEmail !== props.currentUserEmail) return;
  if (!selectedItinerary.value) return;

  showModal({
    title: 'Delete Comment',
    message: 'Delete this comment?',
    type: 'confirm',
    confirmText: 'Delete',
    onConfirm: async () => {
      try {
        await axios.delete(`${API_BASE_URL}/api/itineraries/${selectedItinerary.value.id}/comments/${commentId}`);
        await loadComments(selectedItinerary.value.id);
      } catch (err) {
        console.error('Failed to delete comment', err);
        showModal({ title: 'Error', message: 'Failed to delete comment.', type: 'alert' });
      }
    }
  });
}
</script>

<template>
  <div class="grid grid-cols-1 lg gap-6 items-start">
    <!-- GLOBAL like-list popup -->
    <div
        v-if="likeListVisible"
        class="fixed inset-0 bg-black/40 flex items-center justify-center z-50"
        @click.self="closeLikeList"
    >
      <div class="bg-gray-900 rounded-lg shadow-xl w-full max-w-sm p-4 border border-gray-700">
        <div class="flex justify-between items-start mb-3">
          <h3 class="text-lg font-semibold text-white">
            Likes
          </h3>
<!--          <button-->
<!--              class="text-gray-400 hover:text-gray-600 text-xl leading-none"-->
<!--              @click="closeLikeList"-->
<!--          >-->
<!--            ×-->
<!--          </button>-->
        </div>

        <div v-if="likeListUsers.length === 0" class="text-sm text-gray-500">
          Nobody yet.
        </div>

        <ul v-else class="space-y-2 max-h-48 overflow-y-auto">
          <li
              v-for="u in likeListUsers"
              :key="u.email"
              class="flex items-center justify-between text-sm text-gray-300 border-b border-gray-700 pb-1"
          ><span class="break-all">
            <a
                :href="'/?profile=' + u.email"
                class="text-cyan-400 hover:underline">{{ u.email }}
              </a>
          </span>
            <span class="text-[10px] text-gray-500">
              {{ new Date(u.liked_at).toLocaleString() }}
            </span>
          </li>
        </ul>

        <div class="mt-4 flex justify-end">
          <button
              class="px-3 py-1 text-sm bg-gray-800 border-2 border-cyan-500 text-cyan-500 font-bold rounded-md hover:bg-gray-700 shadow-[0_0_10px_rgba(6,182,212,0.5)] transition"
              @click="closeLikeList"
          >
            Close
          </button>
        </div>
      </div>
    </div>

    <!-- LIST -->
    <div
        class="bg-gray-900 p-6 rounded-xl shadow-lg border border-gray-700 overflow-y-auto max-h-[80vh]"
    >
      <!-- Header -->
      <div
          class="flex justify-between items-start border-b border-gray-700 pb-3 mb-4 flex-col md:flex-row md:items-center"
      >
        <div class="flex flex-col">
          <div class="flex items-center space-x-2">
            <h2 class="text-xl font-semibold text-white">Trips</h2>

            <span
                class="text-[11px] font-medium rounded px-2 py-0.5"
                :class="showAll
                ? 'bg-cyan-900 text-cyan-200 border border-cyan-700'
                : 'bg-gray-800 text-gray-300 border border-gray-600'"
            >
              {{ showAll ? 'All users' : (isViewingSelf ? 'Only me' : 'This user only') }}
            </span>
          </div>

          <p v-if="loading" class="text-cyan-400 text-sm font-medium mt-1">
            ⏳ Loading ⏳
          </p>
          <p
              v-if="error && !loading"
              class="text-red-400 text-sm font-medium mt-1"
          >
            {{ error }}
          </p>
        </div>

        <button
            class="mt-3 md:mt-0 text-sm font-bold text-gray-300 bg-gray-800 border-2 border-gray-500 hover:bg-gray-700 rounded-md px-4 py-2 transition shadow-[0_0_10px_rgba(156,163,175,0.5)]"
            @click="fetchItineraries"
        >
          Refresh
        </button>
      </div>

      <!-- Search Row -->
      <div
          class="mb-4 flex flex-col md:flex-row md:items-center md:space-x-3 space-y-3 md:space-y-0"
      >
        <div class="flex items-center flex-grow space-x-2">
          <label
              class="text-sm font-medium text-gray-300 whitespace-nowrap"
          >Search:</label
          >
          <input
              type="text"
              v-model="filterText"
              placeholder="Search trips..."
              class="flex-grow p-2 border border-gray-600 rounded-md bg-gray-800 text-white focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 transition outline-none"
          />
        </div>

        <div class="flex items-center justify-end space-x-2 shrink-0">
          <button
              type="button"
              class="py-2 px-4 rounded-md text-cyan-500 font-bold bg-gray-800 border-2 border-cyan-500 hover:bg-gray-700 transition shadow-[0_0_10px_rgba(6,182,212,0.5)]"
              @click="viewOnlyThisUser"
          >
            View Only This User
          </button>

          <button
              type="button"
              class="py-2 px-4 rounded-md border-2 transition font-bold shadow-[0_0_10px_rgba(156,163,175,0.5)]"
              :class="isViewingSelf
              ? 'text-gray-300 bg-gray-800 border-gray-500 hover:bg-gray-700'
              : 'text-gray-500 bg-gray-800 border-gray-700 cursor-not-allowed opacity-0'"
              @click="viewAllTrips"
          >
            View All Trips
          </button>
        </div>
      </div>

      <!-- Trips list -->
      <ul class="space-y-2" v-if="filteredItineraries.length > 0">
        <li
            v-for="it in filteredItineraries"
            :key="it.id"
            @click="viewDetails(it.id)"
            class="p-3 border-l-4 rounded-md cursor-pointer transition duration-150 ease-in-out"
            :class="{
            'bg-gray-800 border-cyan-400 shadow-[0_0_10px_rgba(6,182,212,0.5)]': selectedItinerary && selectedItinerary.id === it.id,
            'bg-gray-800 border-gray-600 hover:bg-gray-700 hover:border-gray-500': !(selectedItinerary && selectedItinerary.id === it.id)
          }"
        >
          <p class="font-semibold text-white">
            {{ it.title }}
            <span class="text-sm text-gray-400">
              (
              <a
                  :href="'/?profile=' + it.traveller_email"
                  class="text-cyan-400 hover:underline"
                  @click.stop
              >
                {{ it.traveller_email }}
              </a>
              )
            </span>
          </p>

          <!-- second line: desc + dates -->
          <p class="text-sm text-gray-400">
            {{ it.short_description }}
            <span class="ml-1 text-xs text-gray-500">
              {{ it.start_date }} ~ {{ it.end_date }}
            </span>
          </p>

          <!-- like row -->
          <div class="flex items-center justify-start mt-2 text-xs text-gray-500">
            <div class="flex items-center space-x-2">
              <!-- 愛心按鈕 -->
              <button
                  class="flex items-center space-x-2 text-sm font-medium px-3 py-1.5 rounded-md border"
                  :class="likeMap[it.id]
                ? 'bg-gray-700 text-white border-gray-600 hover:bg-gray-600'
                : 'bg-gray-800 text-gray-300 border-gray-700 hover:bg-gray-700'"
                  @click.stop="toggleLike(it.id)"
                  :title="likeMap[it.id] ? 'Unlike' : 'Like'"

              >
                <span class="text-lg leading-none mr-1">
                  {{ likeMap[it.id] ? '❤️' : '🤍' }}
                </span>
                <span class="font-medium">{{ likeMap[it.id] ? 'Liked' : 'Like' }}</span>
              </button>

              <!-- 數字（灰底圓角，黑字），點了看名單 -->
              <button
                  class="text-[11px] font-medium text-white bg-gray-700 rounded-full px-2 py-0.5 hover:bg-gray-600"
                  @click.stop="showLikeList(it.id)"
              >
                {{ likeCountMap[it.id] ?? 0 }}
              </button>
            </div>
          </div>
        </li>
      </ul>

      <p v-else-if="!loading && !error" class="text-gray-500 italic">
        No result
      </p>
    </div>

    <!-- DETAIL -->
    <div
        class="bg-gray-900 p-6 rounded-xl shadow-lg border border-gray-700 overflow-y-auto max-h-[90vh]"
    >
      <h2 v-if="!selectedItinerary" class="text-xl font-semibold text-gray-400">
        Select a trip to view details
      </h2>

      <div v-else>
        <!-- VIEW MODE -->
        <div v-if="!isEditing">
          <h2
              class="text-3xl font-bold mb-4 text-white border-b border-gray-700 pb-2 text-center"
          >
            {{ selectedItinerary.title }}
          </h2>

          <div class="space-y-2 text-gray-300 text-center border-b border-gray-700 pb-4">
            <p>
              <strong>Owner:</strong>
              <a
                  :href="'/?profile=' + selectedItinerary.traveller_email"
                  class="text-cyan-400 hover:underline"
              >
                {{ selectedItinerary.traveller_email }}
              </a>
            </p>
            <p><strong>Destination:</strong> {{ selectedItinerary.destination }}</p>
            <p><strong>Starting Date:</strong> {{ selectedItinerary.start_date }}</p>
            <p><strong>Ending Date:</strong> {{ selectedItinerary.end_date }}</p>
            <p><strong>Short Description:</strong> {{ selectedItinerary.short_description }}</p>
          </div>

          <div class="pt-4 border-b border-gray-700 pb-4 text-center">
            <p class="font-semibold text-white">Long Description:</p>
            <p class="whitespace-pre-wrap text-gray-300 mt-2">
              {{ selectedItinerary.detail_description }}
            </p>
            <!-- AI Suggestion block -->
            <div v-if="selectedItinerary.aiSuggestion || (aiStatus !== 'idle' && aiStatus !== 'no_suggestion')" class="mt-6 border-t border-gray-700 pt-4">
              <h2 class="text-3xl font-semibold mb-2 bg-[linear-gradient(90deg,_#0A84FF_0%,_#5E5CE6_20%,_#BF5AF2_40%,_#FF2D55_60%,_#FF6961_75%,_#FF9F0A_100%)] bg-clip-text text-transparent">
                Gemini AI Travel Suggestion
              </h2>
              <!-- AI Suggestion status badge -->
              <div class="mt-4 text-center">
  <span
      v-if="aiStatus !== 'idle'&&aiStatus !== 'ok'"
      class="inline-block text-xs px-2 py-0.5 mb-2 rounded border"
      :class="{
      'bg-yellow-900/50 text-yellow-200 border-yellow-700': aiStatus === 'queued',
      'bg-green-900/50 text-green-200 border-green-700': aiStatus === 'ok',
      'bg-gray-800 text-gray-400 border-gray-600': aiStatus === 'no_suggestion',
      'bg-red-900/50 text-red-200 border-red-700': aiStatus === 'error'
    }"
  >
    Status: ● {{ aiStatus.toUpperCase() }}

  </span>
              </div>
              <div class="relative rounded-xl shadow-[0_0_20px_rgba(192,132,252,0.4)] overflow-hidden">
                <!-- Gradient Border -->
                <span class="absolute inset-0 rounded-xl bg-[linear-gradient(90deg,#00C6FF,#0072FF,#FF00E6,#FFD700)] blur-[4px] opacity-100"></span>
                <!-- Inner Background -->
                <span class="absolute inset-[3px] rounded-xl bg-gray-800"></span>

                <!-- Content -->
                <div
                    class="relative z-10 text-gray-300 text-sm p-4 whitespace-pre-wrap leading-relaxed text-left"
                    v-html="formatAiText(selectedItinerary.aiSuggestion)"
                >
                </div>
              </div>
            </div>
            <!--              disclaimer-->
            <span class="text-xs text-gray-500 text-center">Gemini can make mistakes, double-check it. AI Suggestion is not optimised for edited content.</span>
          </div>



          <!-- ❤️ Like block (detail view uses same refs/maps) -->
          <div class="mt-4 flex flex-col items-center space-y-3">
            <div class="space-y-3"></div>
            <button
                @click="toggleLike(selectedItinerary.id)"
                class="flex items-center space-x-2 text-sm font-medium px-3 py-1.5 rounded-md border"
                :class="likeMap[selectedItinerary.id]
                ? 'bg-gray-700 text-white border-gray-600 hover:bg-gray-600'
                : 'bg-gray-800 text-gray-300 border-gray-700 hover:bg-gray-700'"
            >
              <span class="text-lg leading-none">
                {{ likeMap[selectedItinerary.id] ? '❤️' : '🤍' }}
              </span>
              <span>{{ likeMap[selectedItinerary.id] ? 'Liked' : 'Like' }}</span>
            </button>
            <button
                class="text-[11px] font-medium text-white bg-gray-700 rounded-full px-2 py-0.5 hover:bg-gray-600"
                @click="showLikeList(selectedItinerary.id)"
            >
              {{ likeCountMap[selectedItinerary.id] ?? 0 }}
              {{ (likeCountMap[selectedItinerary.id] ?? 0) === 1 ? 'like' : 'likes' }}
            </button>
          </div>

          <!-- 💬 Comments block -->
          <div class="mt-8 border-t border-gray-700 pt-4">
            <h3 class="text-lg font-semibold text-white text-center mb-4">
              Comments
            </h3>

            <!-- 新增留言 (只有登入者能送) -->
            <div
                v-if="props.currentUserEmail"
                class="mb-6 flex flex-col items-stretch space-y-2"
            >
              <textarea
                  v-model="newCommentText"
                  rows="3"
                  class="w-full border border-gray-600 bg-gray-800 text-white rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500"
                  placeholder="Write a comment..."
              ></textarea>

              <button
                  class="self-end bg-gray-800 border-2 border-cyan-500 text-cyan-500 text-sm font-bold px-3 py-1.5 rounded-md hover:bg-gray-700 shadow-[0_0_10px_rgba(6,182,212,0.5)] transition disabled:opacity-50 disabled:shadow-none"
                  :disabled="postingComment"
                  @click="submitComment"
              >
                {{ postingComment ? 'Posting...' : 'Post comment' }}
              </button>
            </div>

            <!-- 留言列表 -->
            <div v-if="loadingComments" class="text-sm text-gray-500 text-center">
              Loading comments...
            </div>

            <div v-else-if="comments.length === 0" class="text-sm text-gray-500 text-center">
              No comments yet.
            </div>

            <ul v-else class="space-y-4 max-h-64 overflow-y-auto">
              <li
                  v-for="c in comments"
                  :key="c.id"
                  class="border border-gray-700 rounded-md p-3 text-sm bg-gray-800"
              >
                <div class="flex justify-between items-start">
                  <div class="text-white break-all">
                    <a
                        :href="'/?profile=' + c.email"
                        class="text-cyan-400 hover:underline font-medium"
                    >
                      {{ c.email }}
                    </a>
                    <span class="ml-2 text-[11px] text-gray-500">
                      {{ new Date(c.created_at).toLocaleString() }}
                    </span>
                  </div>

                  <!-- 刪除按鈕 (只有本人看到) -->
                  <button
                      v-if="c.email === props.currentUserEmail"
                      class="text-[14px] bg-transparent"
                      @click="deleteComment(c.id, c.email)"
                      title="Delete comment"
                  >❌
                  </button>
                </div>

                <p class="mt-2 text-gray-300 whitespace-pre-wrap break-words">
                  {{ c.text }}
                </p>
              </li>
            </ul>
          </div>

          <!-- edit / delete -->
          <div class="flex space-x-3 mt-6 border-t border-gray-700 pt-4 justify-center">
            <button
                v-if="selectedItinerary.traveller_email === props.currentUserEmail"
                class="py-2 px-4 bg-gray-800 border-2 border-cyan-500 text-cyan-500 rounded-md hover:bg-gray-700 transition font-bold shadow-[0_0_10px_rgba(6,182,212,0.5)]"
                @click="startEdit"
            >
              Edit
            </button>

            <button
                v-if="selectedItinerary.traveller_email === props.currentUserEmail"
                class="py-2 px-4 bg-gray-800 border-2 border-red-500 text-red-500 rounded-md hover:bg-gray-700 transition font-bold shadow-[0_0_10px_rgba(239,68,68,0.5)]"
                @click="deleteItinerary"
            >
              Delete
            </button>
          </div>
        </div>

        <!-- EDIT MODE -->
        <div v-else>
          <h3
              class="text-2xl font-bold mb-4 text-white border-b border-gray-700 pb-2 text-center"
          >
            Edit trip: {{ editForm.title }}
          </h3>

          <form @submit.prevent="saveEdit" class="space-y-4">
            <div class="flex flex-col">
              <label class="text-sm font-medium text-gray-300">Title:</label>
              <input
                  type="text"
                  v-model="editForm.title"
                  required
                  class="mt-1 p-2 border border-gray-600 bg-gray-800 text-white rounded-md focus:outline-none focus:ring-cyan-500 focus:border-cyan-500"
              >
            </div>

            <div class="flex flex-col">
              <label class="text-sm font-medium text-gray-300">Destination:</label>
              <input
                  type="text"
                  v-model="editForm.destination"
                  required
                  class="mt-1 p-2 border border-gray-600 bg-gray-800 text-white rounded-md focus:outline-none focus:ring-cyan-500 focus:border-cyan-500"
              >
            </div>

            <div class="flex flex-col">
              <label class="text-sm font-medium text-gray-300">Starting Date:</label>
              <input
                  type="date"
                  v-model="editForm.start_date"
                  required
                  class="mt-1 p-2 border border-gray-600 bg-gray-800 text-white rounded-md focus:outline-none focus:ring-cyan-500 focus:border-cyan-500"
              >
            </div>

            <div class="flex flex-col">
              <label class="text-sm font-medium text-gray-300">Ending Date:</label>
              <input
                  type="date"
                  v-model="editForm.end_date"
                  required
                  class="mt-1 p-2 border border-gray-600 bg-gray-800 text-white rounded-md focus:outline-none focus:ring-cyan-500 focus:border-cyan-500"
              >
            </div>

            <div class="flex flex-col">
              <label class="text-sm font-medium text-gray-300">Short Description:</label>
              <input
                  type="text"
                  v-model="editForm.short_description"
                  maxlength="80"
                  required
                  class="mt-1 p-2 border border-gray-600 bg-gray-800 text-white rounded-md focus:outline-none focus:ring-cyan-500 focus:border-cyan-500"
              >
            </div>

            <div class="flex flex-col">
              <label class="text-sm font-medium text-gray-300">Long Description:</label>
              <textarea
                  v-model="editForm.detail_description"
                  rows="5"
                  class="mt-1 p-2 border border-gray-600 bg-gray-800 text-white rounded-md focus:outline-none focus:ring-cyan-500 focus:border-cyan-500"
              ></textarea>
            </div>

            <div class="flex space-x-3 pt-2 justify-center">
              <button
                  class="py-2 px-4 rounded-md bg-gray-800 font-bold border-2 border-green-500 text-green-500 hover:bg-gray-700 transition shadow-[0_0_10px_rgba(34,197,94,0.5)]"
                  type="submit"
              >
                Done
              </button>

              <button
                  class="py-2 px-4 rounded-md bg-gray-800 font-bold border-2 border-gray-500 text-gray-400 hover:bg-gray-700 transition shadow-[0_0_10px_rgba(156,163,175,0.5)]"
                  type="button"
                  @click="cancelEdit"
              >
                Cancel
              </button>
            </div>

            <p
                :class="{
                'text-green-400': editMessage.includes('Successfully'),
                'text-red-400': !editMessage.includes('Successfully')
              }"
                class="mt-3 text-sm font-medium text-center"
            >
              {{ editMessage }}
            </p>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>