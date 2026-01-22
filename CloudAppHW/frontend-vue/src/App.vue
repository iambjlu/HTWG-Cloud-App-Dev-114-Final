<script setup>
import {ref, computed, onMounted, watch} from 'vue';
import axios from 'axios';
import {auth} from './firebase';
import {onAuthStateChanged, onIdTokenChanged, signOut} from 'firebase/auth';

import AuthAndCreate from './components/AuthAndCreate.vue';
import ItineraryManager from './components/ItineraryManager.vue';
import ProfileCard from './components/ProfileCard.vue';
import MerchantDashboard from './components/MerchantDashboard.vue';
import AdminDashboard from './components/AdminDashboard.vue';
import GlobalModal from './components/GlobalModal.vue';
import DynamicFeed from './components/DynamicFeed.vue';
import { showModal } from './utils/modal.js';

const isLoading = ref(false);
const isMerchantMode = ref(false);
const isAdminMode = ref(false);
const membershipTier = ref('Free');
const isAdminUser = ref(false);

const isAuthenticated = ref(false);
const userEmail = ref(null);
const refreshKey = ref(0);
const myItineraryCount = ref(0);
const viewEmail = ref(null);

const currentTab = ref('dashboard'); // 'dashboard' | 'explore'

// --- Auth & API Logic ---

(async () => {
  const u = auth.currentUser;
  if (u) {
    const t = await u.getIdToken();
    axios.defaults.headers.common['Authorization'] = `Bearer ${t}`;
  }
})();

onIdTokenChanged(auth, async (user) => {
  if (user) {
    const t = await user.getIdToken(/* forceRefresh */ true);
    axios.defaults.headers.common['Authorization'] = `Bearer ${t}`;
  } else {
    delete axios.defaults.headers.common['Authorization'];
  }
});

axios.interceptors.request.use(
    (config) => {
      isLoading.value = true;
      return config;
    },
    (error) => {
      isLoading.value = false;
      return Promise.reject(error);
    }
);

axios.interceptors.response.use(
    (response) => {
      isLoading.value = false;
      return response;
    },
    (error) => {
      isLoading.value = false;
      return Promise.reject(error);
    }
);

async function applyAuthHeader(user) {
  if (!user) {
    delete axios.defaults.headers.common['Authorization'];
    return;
  }
  const token = await user.getIdToken();
  axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
}

const initialTripId = ref(null);
// ...

function syncViewEmailFromURL() {
  const params = new URLSearchParams(window.location.search);
  const qEmail = params.get('profile');
  const qTrip = params.get('trip');

  if (qEmail && qEmail.includes('@')) {
    viewEmail.value = qEmail;
  } else {
    viewEmail.value = userEmail.value;
  }
  
  if (qTrip) {
    initialTripId.value = qTrip;
  }
}

function goHome() {
  window.location.href = '/';
}

function handleItineraryUpdate() {
  refreshKey.value++;
  fetchMyItineraryCount();
}

async function fetchMyItineraryCount() {
  if (!userEmail.value) {
    myItineraryCount.value = 0;
    return;
  }
  try {
    const res = await axios.get(`${import.meta.env.VITE_API_BASE_URL}/api/itineraries/count/${encodeURIComponent(userEmail.value)}`);
    myItineraryCount.value = res.data.count || 0;
  } catch (e) {
    console.error('Failed to fetch itinerary count:', e);
    myItineraryCount.value = 0;
  }
}

async function handleLogout() {
  await signOut(auth);
  membershipTier.value = 'Free';
  isAdminUser.value = false;
  isAdminMode.value = false; // Reset admin view
}

async function handleUpgradeClick() {
  if (membershipTier.value === 'Free') {
    showModal({
      title: 'Upgrade to Premium for 1 year',
      message: `
        <div class="text-left space-y-3">
          <p class="font-semibold">Please use the convenience store payment code below. Your Premium privilege will be activated by admin within 7 days after payment.</p>
          <div class="mt-4 flex justify-center">
            <img src="https://www.newebpay.com/ud/img/service/cvs/pic04.png" alt="7-11 code" class="rounded-lg border border-gray-600 max-w-full" style="max-height: 200px;" />
          </div>
        </div>
      `,
      type: 'alert'
    });
  }
}

const effectiveEmail = computed(() => viewEmail.value || userEmail.value || '');

const isViewingSomeoneElse = computed(() => {
  if (!userEmail.value && viewEmail.value) return true;
  return (
      userEmail.value &&
      viewEmail.value &&
      userEmail.value !== viewEmail.value
  );
});

function handleNoData() {
  if (isViewingSomeoneElse.value) {
    showModal({
      title: 'User Not Found',
      message: 'This user has no trips or does not exist. Returning to homepage.',
      type: 'alert',
      onConfirm: () => {
        window.location.href = "/";
      },
      onCancel: () => {
        window.location.href = "/";
      }
    });
  }
}

function setTab(tab) {
  currentTab.value = tab;
}

onMounted(() => {
  onAuthStateChanged(auth, async (user) => {
    if (user) {
      isAuthenticated.value = true;
      userEmail.value = user.email || null;
      await applyAuthHeader(user);

      try {
        const res = await axios.post(`${import.meta.env.VITE_API_BASE_URL}/api/travellers/ensure`, {
          name: user.displayName || 'New User'
        });
        membershipTier.value = res.data.membership_tier || 'Free';
        isAdminUser.value = !!res.data.is_admin;
        
        // Check merchant mode after auth - only allow admins
        const params = new URLSearchParams(window.location.search);
        if (params.get('panel') === 'merchant') {
          if (isAdminUser.value) {
            isMerchantMode.value = true;
          } else {
            // Non-admin trying to access merchant panel, redirect to home
            showModal({
              title: 'Access Denied',
              message: 'You do not have permission to access the Merchant Portal. Admin privileges required.',
              type: 'alert',
              onConfirm: () => {
                window.location.href = '/';
              }
            });
          }
        }
        
        // Fetch user's itinerary count for Free tier limit check
        fetchMyItineraryCount();
      } catch (err) {
        console.error("Failed to ensure user in DB:", err);
      }

      localStorage.setItem('tripplanner_userEmail', userEmail.value || '');
    } else {
      isAuthenticated.value = false;
      userEmail.value = null;
      await applyAuthHeader(null);
      await applyAuthHeader(null);
      localStorage.removeItem('tripplanner_userEmail');
      membershipTier.value = 'Free';
      isAdminUser.value = false;
      
      // Non-authenticated user trying to access merchant panel
      const params = new URLSearchParams(window.location.search);
      if (params.get('panel') === 'merchant') {
        showModal({
          title: 'Login Required',
          message: 'Please login with an admin account to access the Merchant Portal.',
          type: 'alert',
          onConfirm: () => {
            window.location.href = '/';
          }
        });
      }
    }
    syncViewEmailFromURL();
  });

  syncViewEmailFromURL();
});

watch(userEmail, () => {
  const params = new URLSearchParams(window.location.search);
  const qEmail = params.get('profile');
  if (!qEmail) {
    viewEmail.value = userEmail.value;
  }
});

watch(isLoading, (newValue) => {
  if (newValue) {
    document.documentElement.classList.add('is-loading');
  } else {
    document.documentElement.classList.remove('is-loading');
  }
});

// ... (previous code)

const authAndCreateRef = ref(null);

function handleCloneTrip(tripData) {
  // Switch to dashboard first if needed
  viewEmail.value = null; // Go to my profile
  window.history.pushState({}, '', '/'); // Update URL
  currentTab.value = 'dashboard';
  
  // Wait for Vue to re-render AuthAndCreate
  setTimeout(() => {
    if (authAndCreateRef.value) {
      authAndCreateRef.value.fillForm(tripData);
    }
  }, 100);
}

// ... (existing functions)

</script>

<template>
  <GlobalModal />
  
  <!-- Loading Overlay -->
  <div class="loading-overlay" v-if="isLoading">
    <div class="loading-box">
      <div class="cupertino-spinner">
        <div></div><div></div><div></div><div></div>
        <div></div><div></div><div></div><div></div>
      </div>
    </div>
  </div>
  
  <div class="min-h-screen bg-black">
    
    <!-- MODE: Merchant Dashboard -->
    <MerchantDashboard v-if="isMerchantMode" />
    <AdminDashboard v-else-if="isAdminMode" @close="isAdminMode = false" />
    
    <!-- MODE: Standard App -->
    <div v-else>
      <header v-if="!isLoading"
              class="bg-cyan-600 text-white
                 py-3 px-2 rounded-lg shadow-lg mb-4
                 flex justify-between items-center
                 sticky top-2" style="z-index: 9999;">
        <h1 class="text-2xl font-bold flex items-center space-x-2 relative">
          <strong><span><a href="/" class="text-white">DragonFlyX</a></span></strong>
          
          <span
              v-if="isAuthenticated && isViewingSomeoneElse"
              class="text-xs font-normal bg-white/20 rounded px-2 py-0.5"
          >
            viewing {{ effectiveEmail }}
          </span>
        </h1>
        
        <div class="flex flex-col items-end gap-0.5">
          <div v-if="userEmail" class="flex items-center space-x-3">
            <!-- Admin Toggle -->
            <button v-if="isAdminUser" @click="isAdminMode = !isAdminMode" class="text-xs bg-red-900 text-red-100 px-2 py-1 rounded border border-red-500 hover:bg-red-800 transition">
               {{ isAdminMode ? 'Exit Admin' : 'Admin Portal' }}
            </button>
            
            <!-- Tier Badge / Upgrade Button -->
             <button
                @click="handleUpgradeClick"
                class="flex items-center space-x-1 px-3 py-1 rounded-full border transition text-sm font-bold"
                :class="membershipTier === 'Premium' ? 'bg-yellow-500/20 border-yellow-500 text-yellow-500 cursor-default' : 'bg-gray-700 border-gray-500 text-gray-300 hover:bg-gray-600'"
            >
              <span v-if="membershipTier === 'Premium'">👑 Premium</span>
              <span v-else>☁️ Standard</span>
              <span v-if="membershipTier !== 'Premium'" class="ml-1 text-[10px] uppercase bg-cyan-700/50 px-1 rounded">Upgrade</span>
            </button>

            <p class="text-sm font-semibold text-white">{{ userEmail }}</p>
            <button
                @click="handleLogout"
                class="py-1 px-3 bg-gray-800 border-2 border-red-500 text-red-500 text-sm font-bold rounded-md hover:bg-gray-700 transition shadow-[0_0_10px_rgba(239,68,68,0.5)] z-9997"
            >
              Logout
            </button>
          </div>
          <div v-else class="flex items-center space-x-3">
            <button
                @click="goHome"
                class="py-1 px-3 bg-gray-800 border-2 border-cyan-500 text-cyan-500 text-sm font-bold rounded-md hover:bg-gray-700 transition shadow-[0_0_10px_rgba(6,182,212,0.5)] z-9997"
            >
              Login
            </button>
          </div>
        </div>
      </header>
      
      <!-- Ghost Header for spacing during loading if needed, or just keep simple -->
      <header v-if="isLoading"
              class="bg-cyan-600 text-white py-3 px-2 rounded-lg shadow-lg mb-4 flex justify-between items-center sticky top-2" style="z-index: 9999;cursor: wait;">
         <h1 class="text-2xl font-bold"><strong><span><a class="text-white">DragonFlyX</a></span></strong></h1>
         <div class="flex items-center space-x-3"><h1 class="text-2xl font-bold"><strong><span><a class="text-white">🐲 🚁</a></span></strong></h1></div>
      </header>

      <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 max-w-7xl mx-auto">
        <!-- Auth / Profile Column -->
        <div v-if="!isAuthenticated && !viewEmail" class="lg:col-span-12 grid grid-cols-1 lg:grid-cols-12 gap-6">
           <!-- Login Section (Left) -->
           <div class="lg:col-span-4 space-y-6 order-1">
            <div class="bg-gray-900 p-6 rounded-xl shadow-lg border border-gray-700">
              <h2 class="text-2xl font-bold mb-1 text-white text-center">🐲 DragonFlyX 🚁</h2>
              <div class="space-y-1 text-gray-300"><p><strong>The Trip Planner.</strong></p></div>
              <br>
              <div class="space-y-1 text-gray-300 text-center md:text-left">
                <p><strong>Team name:</strong> <span class="text-cyan-400">Kenting 🏖️</span></p>
                <p><strong>Team member:</strong> Po-Chun Lu</p>
                <p><strong>Professor:</strong> Dr. Markus Eilsperger</p>
              </div>
            </div>
            <AuthAndCreate @set-loading="isLoading = $event" :membershipTier="membershipTier" />
          </div>

           <!-- New Feed Section for Guest (Right) -->
            <div class="lg:col-span-8 order-2">
               <DynamicFeed :membershipTier="membershipTier" />
            </div>
        </div>
        
        <template v-else>
          <div class="lg:col-span-5 space-y-6 h-full flex flex-col">
            <div class="bg-gray-900 p-4 rounded-xl shadow-lg border border-gray-700 shrink-0">
              <h2 class="text-2xl font-bold mb-1 text-white text-center">🐲 DragonFlyX 🚁</h2>
              <!-- Tab Switcher -->
              <div class="flex justify-center mt-4 bg-gray-800 p-1 rounded-lg w-fit mx-auto">
                 <button 
                    @click="setTab('dashboard')"
                    class="px-6 py-1.5 rounded-md text-sm font-bold transition-all"
                    :class="currentTab === 'dashboard' ? 'bg-cyan-600 text-white shadow-lg' : 'text-gray-400 hover:text-white'"
                 >
                    {{ isViewingSomeoneElse ? 'Profile' : 'My Trips' }}
                 </button>
                 <button 
                    @click="setTab('explore')"
                    class="px-6 py-1.5 rounded-md text-sm font-bold transition-all"
                    :class="currentTab === 'explore' ? 'bg-purple-600 text-white shadow-lg' : 'text-gray-400 hover:text-white'"
                 >
                    Explore
                 </button>
              </div>
            </div>
            
            <div class="shrink-0">
               <ProfileCard
                  :userEmail="effectiveEmail"
                  :currentUserEmail="userEmail"
               />
            </div>

            <div class="grow">
                <AuthAndCreate
                    v-if="!isViewingSomeoneElse"
                    ref="authAndCreateRef"
                    :userEmail="userEmail"
                    :isAuthenticated="isAuthenticated"
                    :membershipTier="membershipTier"
                    :itineraryCount="myItineraryCount"
                    @itinerary-updated="handleItineraryUpdate"
                    @set-loading="isLoading = $event"
                />
                <div
                    v-else
                    class="bg-yellow-900/50 text-yellow-100 text-sm rounded-xl border border-yellow-700 shadow p-6"
                >
                  <p class="font-semibold text-yellow-200 text-center">
                    Viewing {{ effectiveEmail }}'s trips
                  </p>
                  <button
                      class="mt-4 w-full py-2 px-4 bg-gray-800 border-2 border-yellow-500 text-yellow-500 font-bold rounded-md hover:bg-gray-700 transition shadow-[0_0_10px_rgba(234,179,8,0.5)]"
                      @click="goHome"
                  >
                    Go to Homepage
                  </button>
                </div>
            </div>
          </div>
          
          <div class="lg:col-span-7 space-y-3 h-full overflow-hidden">
            <DynamicFeed v-if="currentTab === 'explore'" :currentUserEmail="userEmail" :membershipTier="membershipTier" />
            <ItineraryManager
                v-else
                :travellerEmail="effectiveEmail"
                :currentUserEmail="userEmail"
                :membershipTier="membershipTier"
                :refreshSignal="refreshKey"
                :initialTripId="initialTripId"
                @no-data="handleNoData"
                @clone-trip="handleCloneTrip"
            />
          </div>
        </template>
      </div> <!-- End Grid -->
    </div> <!-- End Else Normal Mode -->
  </div> <!-- End Min Screen -->
</template>

<style>
html.is-loading {
  overflow: hidden;
}
</style>

<style scoped>
.loading-overlay {
  position: fixed;
  inset: 0;
  z-index: 9998;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}
.loading-box {
  background-color: rgba(0,0,0, 0.5);
  backdrop-filter: blur(7px);
  -webkit-backdrop-filter: blur(5px);
  border-radius: 20px;
  box-shadow: 0 4px 30px rgba(255, 255, 255, 0.2);
  padding: 5rem 5rem;
  pointer-events: all;
}
.cupertino-spinner {
  width: 60px;
  height: 60px;
  position: relative;
}
.cupertino-spinner div {
  position: absolute;
  width: 4px;
  height: 15px;
  background-color: #ffffff;
  border-radius: 2px;
  left: 28px;
  top: 5px;
  transform-origin: 2px 25px;
  opacity: 0;
  animation: spinner-fade 1s linear infinite;
}
@keyframes spinner-fade {
  from { opacity: 0.85; }
  to { opacity: 0.15; }
}
.cupertino-spinner div:nth-child(1) { transform: rotate(0deg); animation-delay: -0.875s; }
.cupertino-spinner div:nth-child(2) { transform: rotate(45deg); animation-delay: -0.75s; }
.cupertino-spinner div:nth-child(3) { transform: rotate(90deg); animation-delay: -0.625s; }
.cupertino-spinner div:nth-child(4) { transform: rotate(135deg); animation-delay: -0.5s; }
.cupertino-spinner div:nth-child(5) { transform: rotate(180deg); animation-delay: -0.375s; }
.cupertino-spinner div:nth-child(6) { transform: rotate(225deg); animation-delay: -0.25s; }
.cupertino-spinner div:nth-child(7) { transform: rotate(270deg); animation-delay: -0.125s; }
.cupertino-spinner div:nth-child(8) { transform: rotate(315deg); animation-delay: 0s; }
</style>