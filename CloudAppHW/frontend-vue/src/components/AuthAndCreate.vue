<!--AuthAndCreate.vue-->
<script setup>
import { ref } from 'vue';
import axios from 'axios';
import { auth } from '../firebase';
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword, signOut,
  updateProfile
} from 'firebase/auth';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

const props = defineProps({
  userEmail: {
    type: String,
    default: null
  },
  isAuthenticated: {
    type: Boolean,
    default: false
  },
  membershipTier: {
    type: String,
    default: 'Free'
  },
  itineraryCount: {
    type: Number,
    default: 0
  }
});

// <--
// 1. FIX:
// 告訴 Vue 我們新增了一個 'set-loading' 事件
// -->
const emit = defineEmits(['itinerary-updated', 'request-logout', 'set-loading']);

// --- Auth 狀態 ---
const authEmail = ref('');
const authPassword = ref('');
const authName = ref('');
const authMessage = ref('');

// Firebase 註冊
const register = async () => {
  authMessage.value = '';
  if (!authEmail.value || !authEmail.value.includes('@')) {
    authMessage.value = 'Invaild E-mail Address';
    return;
  }
  if (!authPassword.value || authPassword.value.length < 6) {
    authMessage.value = 'Password must be at least 6 characters';
    return;
  }

  // <--
  // 2. FIX:
  // 在 "try" 之前，手動觸發 Spinner ON
  // -->
  emit('set-loading', true);

  try {
    // 1. (Spinner 正在轉...)
    const cred = await createUserWithEmailAndPassword(auth, authEmail.value, authPassword.value);

    // 2. (Spinner 正在轉...)
    if (authName.value) {
      await updateProfile(cred.user, { displayName: authName.value });
    }

    // 3. (Spinner 正在轉...)
    // 這個 call 會被 App.vue "攔截"
    await axios.post(`${API_BASE_URL}/api/travellers/ensure`, {
      name: authName.value || 'New User'
    });

    // 4. (Axios 成功後，App.vue 攔截器會自動 'set-loading' to false)

    authMessage.value = `Register & Login Successfully!`;

    // 清空輸入框
    authEmail.value = '';
    authPassword.value = '';
    authName.value = '';

  } catch (err) {
    console.error(err);
    authMessage.value = err?.message || 'Register failed';

    // <--
    // 3. FIX:
    // 如果 Firebase 或 Axios "失敗"，
    // 攔截器可能沒跑到，所以我們要手動關閉 Spinner
    // -->
    emit('set-loading', false);
  }
};

// ---
// 登入 (login) function 也要加一樣的邏輯
// ---
const login = async () => {
  authMessage.value = '';

  // <-- 1. 手動 ON -->
  emit('set-loading', true);
  try {
    // 2. (Spinner 正在轉...)
    const cred = await signInWithEmailAndPassword(auth, authEmail.value, authPassword.value);

    // 3. 登入後，我們也 call 'ensure'
    // 這會 "自動" 關閉 spinner
    await axios.post(`${API_BASE_URL}/api/travellers/ensure`, {
      name: cred.user.displayName || 'Logged In User'
    });

    authMessage.value = `Login Successfully！User Email: ${cred.user.email}`;

  } catch (err) {
    console.error(err);
    authMessage.value = err?.message || 'Login failed';
    // <-- 3. 失敗時手動 OFF -->
    emit('set-loading', false);
  }
};

const createTitle = ref('');
const createDestination = ref('');
const createStartDate = ref('');
const createEndDate = ref('');
const createShortDesc = ref('');
const createDetailDesc = ref('');
const createMessage = ref('');
const createAiOption = ref('standard');
const createIsPrivate = ref(false);

const createItinerary = async () => {
  createMessage.value = '';

  if (
      !createTitle.value ||
      !createDestination.value ||
      !createStartDate.value ||
      !createEndDate.value ||
      !createShortDesc.value
  ) {
    createMessage.value = 'Heads up: All fields are required.';
    return;
  }

  if (createShortDesc.value.length > 80) {
    createMessage.value = 'Short Description should not longer than 80 letters.';
    return;
  }

  if (!props.userEmail) {
    createMessage.value = 'Please login or register.';
    return;
  }

  // Free user limit: max 2 itineraries
  if (props.membershipTier !== 'Premium' && props.itineraryCount >= 2) {
    createMessage.value = '⚠️ Free users can only create up to 2 trips. Upgrade to Premium for unlimited trips!';
    return;
  }

  try {
    const response = await axios.post(`${API_BASE_URL}/api/itineraries`, {
      title: createTitle.value,
      destination: createDestination.value,
      start_date: createStartDate.value,
      end_date: createEndDate.value,
      short_description: createShortDesc.value,
      short_description: createShortDesc.value,
      detail_description: createDetailDesc.value,
      enable_ai: createAiOption.value !== 'off',
      ai_model_tier: createAiOption.value,
      is_private: createIsPrivate.value
    });

    createMessage.value = `Trip "${createTitle.value}" Created Successfully！`;

    // Reset form
    createTitle.value = createDestination.value = createStartDate.value = createEndDate.value = createShortDesc.value = createDetailDesc.value = '';
    createIsPrivate.value = false;

    emit('itinerary-updated');
    console.log('Trip created: ', response.data);
    // Call the AI suggestion alert
    // if (response.data && response.data.suggestion) {
    //   setTimeout(() => {
    //     alert("Your trip has been successfully uploaded!\n"+response.data.suggestion);
    //   }, 100);
    // }

  } catch (error) {
    console.error('Error creating trip: ', error);
    if (error.response && error.response.data && error.response.data.message) {
      createMessage.value = `Error: ${error.response.data.message}`;
    } else {
      createMessage.value = 'Error creating trip. Check console.';
    }
  }
};

// Exposed function to fill form (e.g. from cloning)
const fillForm = (data) => {
  if (!data) return;
  createTitle.value = data.title || '';
  createDestination.value = data.destination || '';
  // Don't copy dates, let user pick
  createShortDesc.value = data.short_description || '';
  createDetailDesc.value = data.detail_description || '';
  // Optional: Scroll to form
  const formEl = document.getElementById('createTitle');
  if (formEl) formEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
};

defineExpose({ fillForm });
</script>

<template>
  <div class="space-y-6">
    <div v-if="!isAuthenticated" class="bg-gray-900 p-6 rounded-xl shadow-lg border border-gray-700">
      <h2 class="text-xl font-semibold mb-4 text-white border-b border-gray-700 pb-2">Register or Login</h2>
      <form @submit.prevent class="space-y-4">
        <div class="flex flex-col">
          <label for="authEmail" class="text-sm font-medium text-gray-300">E-mail</label>
          <input
              type="email"
              id="authEmail"
              v-model="authEmail"
              required
              class="mt-1 p-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:ring-cyan-500 focus:border-cyan-500 outline-none"
              placeholder="Please enter your Email"
          >
        </div>
        <div class="flex flex-col">
          <label for="authPassword" class="text-sm font-medium text-gray-300">Password</label>
          <input
              type="password"
              id="authPassword"
              v-model="authPassword"
              required
              class="mt-1 p-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:ring-cyan-500 focus:border-cyan-500 outline-none"
              placeholder="At least 6 characters"
              @keyup.enter="login"
          >
        </div>
        <div class="flex flex-col">
          <label for="authName" class="text-sm font-medium text-gray-300">Name (for Register)</label>
          <input
              type="text"
              id="authName"
              v-model="authName"
              class="mt-1 p-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:ring-cyan-500 focus:border-cyan-500 outline-none"
              placeholder="Please enter your name"
          >
          <p class="text-xs text-gray-400 mt-1">
            First time? Use Register. Otherwise Login directly.
          </p>
        </div>

        <div class="grid grid-cols-2 gap-2">
          <button
              class="w-full py-2 px-4 rounded-md bg-gray-800 border-2 border-gray-500 text-gray-400 font-bold hover:bg-gray-700 transition shadow-[0_0_10px_rgba(156,163,175,0.5)]"
              @click="register"
              type="button"
          >
            Register
          </button>
          <button
              class="w-full py-2 px-4 rounded-md bg-gray-800 border-2 border-cyan-500 text-cyan-500 font-bold hover:bg-gray-700 transition shadow-[0_0_10px_rgba(6,182,212,0.5)]"
              @click="login"
              type="button"
          >
            Login
          </button>
        </div>
        
      </form>
      <p :class="{'text-green-400': authMessage.includes('Successfully'), 'text-red-400': !authMessage.includes('Successfully')}" class="mt-3 text-sm font-medium">
        {{ authMessage }}
      </p>
    </div>

    <div v-else class="bg-gray-900 p-6 rounded-xl shadow-lg border border-gray-700">
      <h2 class="text-xl font-semibold mb-4 text-white border-b border-gray-700 pb-2">Create new trip</h2>

      <form @submit.prevent="createItinerary" class="space-y-4">
        <div class="flex flex-col">
          <label for="createTitle" class="text-sm font-medium text-gray-300">Title:</label>
          <input type="text" id="createTitle" v-model="createTitle" required class="mt-1 p-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:ring-cyan-500 focus:border-cyan-500 outline-none" placeholder="Family Trip? Honeymoon?">
        </div>
        <div class="flex flex-col">
          <label for="createDestination" class="text-sm font-medium text-gray-300">Destination:</label>
          <input type="text" id="createDestination" v-model="createDestination" required placeholder="Location?" class="mt-1 p-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:ring-cyan-500 focus:border-cyan-500 outline-none">
        </div>
        <div class="flex flex-col">
          <label for="createStartDate" class="text-sm font-medium text-gray-300">Starting Date:</label>
          <input type="date" id="createStartDate" v-model="createStartDate" required class="mt-1 p-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:ring-cyan-500 focus:border-cyan-500 outline-none">
        </div>
        <div class="flex flex-col">
          <label for="createEndDate" class="text-sm font-medium text-gray-300">Ending Date:</label>
          <input type="date" id="createEndDate" v-model="createEndDate" required class="mt-1 p-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:ring-cyan-500 focus:border-cyan-500 outline-none">
        </div>
        <div class="flex flex-col">
          <label for="createShortDesc" class="text-sm font-medium text-gray-300">Short Description:</label>
          <input type="text" id="createShortDesc" v-model="createShortDesc" maxlength="80" required class="mt-1 p-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:ring-cyan-500 focus:border-cyan-500 outline-none" placeholder="With Who? Note?">
        </div>
        <div class="flex flex-col">
          <label for="createDetailDesc" class="text-sm font-medium text-gray-300">Long Description:</label>
          <textarea id="createDetailDesc" v-model="createDetailDesc" rows="3" class="mt-1 p-2 bg-gray-800 text-white border border-gray-600 rounded-md focus:ring-cyan-500 focus:border-cyan-500 outline-none" placeholder="Transportation Plan? Must-eat? Must-buy? Note?"></textarea>
        </div>

        <div class="flex flex-col space-y-2 mt-2">

          <label class="text-sm font-medium text-gray-300">AI Suggestion</label>
          <div class="space-y-2">
            <!-- Advanced -->
            <label class="flex items-center space-x-2 p-3 rounded-lg border transition-all"
                   :class="[
                     createAiOption === 'advanced' ? 'bg-cyan-900/40 border-cyan-500' : 'bg-gray-800 border-gray-700',
                     props.membershipTier !== 'Premium' ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'
                   ]">
              <input type="radio" value="advanced" v-model="createAiOption" :disabled="props.membershipTier !== 'Premium'" class="text-cyan-500 bg-gray-900 border-gray-600 focus:ring-cyan-500">
              <span class="text-sm text-white font-semibold">
                Advanced Model: Gemini 3
                <span v-if="props.membershipTier !== 'Premium'" class="text-gray-500 ml-1 text-xs">(Premium Only 👑)</span>
                <span v-else class="text-yellow-400 ml-1">👑</span>
              </span>
            </label>
            
            <!-- Standard -->
             <label class="flex items-center space-x-2 p-3 rounded-lg border transition-all"
                   :class="createAiOption === 'standard' ? 'bg-cyan-900/40 border-cyan-500' : 'bg-gray-800 border-gray-700'">
              <input type="radio" value="standard" v-model="createAiOption" class="text-cyan-500 bg-gray-900 border-gray-600 focus:ring-cyan-500">
              <span class="text-sm text-white">Standard Model: Gemma 3</span>
            </label>
            
            <!-- Off -->
             <label class="flex items-center space-x-2 p-3 rounded-lg border transition-all"
                   :class="createAiOption === 'off' ? 'bg-red-900/20 border-red-500' : 'bg-gray-800 border-gray-700'">
              <input type="radio" value="off" v-model="createAiOption" class="text-red-500 bg-gray-900 border-gray-600 focus:ring-red-500">
              <span class="text-sm text-white">Off</span>
            </label>
          </div>
        </div>

        <!-- Private Visibility Option -->
        <div class="flex flex-col space-y-2 mt-4" :class="{ 'opacity-60 grayscale-[0.5]': props.membershipTier !== 'Premium' }">
          <label class="text-sm font-medium text-gray-300">Visibility</label>
          <label class="flex items-center space-x-2 p-3 rounded-lg border transition-all"
                 :class="[
                   createIsPrivate ? 'bg-purple-900/40 border-purple-500' : 'bg-gray-800 border-gray-700',
                   props.membershipTier !== 'Premium' ? 'cursor-not-allowed bg-gray-900/50 border-gray-800' : 'cursor-pointer'
                 ]">
            <input type="checkbox" v-model="createIsPrivate" :disabled="props.membershipTier !== 'Premium'" class="text-purple-500 bg-gray-900 border-gray-600 focus:ring-purple-500 rounded">
            <span class="text-sm text-white font-semibold flex items-center">
              Private 👑
              <span v-if="props.membershipTier !== 'Premium'" class="text-gray-500 ml-2 text-xs bg-gray-700/50 px-2 py-0.5 rounded-full">(Premium Only)</span>
              <span v-else class="text-purple-400 ml-2 text-xs font-normal">Only you can see this trip</span>
            </span>
          </label>
        </div>

        <div class="relative group mt-6 pb-1">
          <button
              class="relative w-full py-3 px-6 rounded-xl text-white bg-black font-bold text-lg hover:text-cyan-400 transition-all duration-300 z-10 overflow-hidden shadow-[0_0_20px_rgba(192,132,252,0.4)] hover:shadow-[0_0_35px_rgba(192,132,252,0.6)]"
              type="submit"
          >
            <!-- Glowing border effect -->
            <span class="absolute inset-0 rounded-xl p-[3px] bg-[linear-gradient(90deg,#00C6FF,#0072FF,#FF00E6,#FFD700)] opacity-100 blur-[4px] group-hover:blur-[6px] transition-all duration-300 -z-10"></span>
            
            <!-- Inner black background -->
            <span class="absolute inset-[3px] rounded-xl bg-gray-800 hover:bg-gray-700 -z-0"></span>
            
            <!-- Text -->
            <span class="relative z-10">🌏 Create 🐲</span>
          </button>
        </div>
      </form>
      <p class="text-sm font-medium text-gray-400 mt-2">
        Note:
      </p>
      <p class="text-sm font-medium text-gray-400">
        With Creating this trip, everyone on DragonFlyX can see it.
      </p>
      <p class="text-sm font-medium text-gray-400">
        Google AI will make a suggestion for your trip like magic!
      </p>
      <p :class="{'text-green-400': createMessage.includes('Successfully'), 'text-red-400': !createMessage.includes('Successfully')}" class="mt-3 text-sm font-medium">
        {{ createMessage }}
      </p>
    </div>
  </div>
</template>