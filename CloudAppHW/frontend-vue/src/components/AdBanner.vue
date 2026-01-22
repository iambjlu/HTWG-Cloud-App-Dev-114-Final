<script setup>
import { ref, watch, onMounted } from 'vue';
import axios from 'axios';
import { showModal } from '../utils/modal.js';

const props = defineProps({
  destination: {
    type: String,
    default: ''
  },
  membershipTier: {
    type: String,
    default: 'Free'
  }
});

const ads = ref([]);
const loading = ref(false);
const isVisible = ref(true);
const isFallback = ref(false);

const AD_SERVICE_URL = import.meta.env.VITE_AD_SERVICE_URL || '/api/ads';

async function fetchAds() {
  loading.value = true;
  isVisible.value = true;
  isFallback.value = false;
  
  try {
    let fetchedAds = [];
    
    // 1. If destination provided, try strict match
    if (props.destination) {
       const res = await axios.get(AD_SERVICE_URL, {
        params: { destination: props.destination }
      });
      fetchedAds = res.data || [];
    }

    if (fetchedAds.length > 0) {
      ads.value = fetchedAds;
    } else {
      // 2. Fallback (or if no destination): Fetch all/random ads
      const fallbackRes = await axios.get(AD_SERVICE_URL);
      const allAds = fallbackRes.data || [];
      if (allAds.length > 0) {
        // Shuffle and pick 2
        ads.value = allAds.sort(() => 0.5 - Math.random()).slice(0, 2);
        isFallback.value = true;
      } else {
        ads.value = [];
      }
    }
  } catch (err) {
    console.error('Failed to fetch ads:', err);
    ads.value = [];
  } finally {
    loading.value = false;
  }
}

function handleClose() {
  if (props.membershipTier === 'Premium') {
    isVisible.value = false;
  } else {
    showModal({
      title: 'Premium Feature',
      message: 'Only Premium members can hide advertisements.',
      type: 'alert'
    });
  }
}

watch(() => props.destination, (newVal) => {
  if(newVal) fetchAds();
});

onMounted(() => {
  fetchAds();
});
</script>

<template>
  <div v-if="ads.length > 0 && isVisible" class="my-6 pt-4 border-t border-gray-700 relative group/info">
    <div class="flex justify-between items-center mb-4">
      <h3 class="text-xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 to-orange-500 inline-flex items-center gap-2">
        <span>🎁</span> 
        <span v-if="!isFallback">Exclusive Local Deals in {{ destination }}</span>
        <span v-else>Recommended Travel Deals</span>
      </h3>
      
      <!-- Close Button -->
      <button 
        @click="handleClose"
        class="text-gray-500 hover:text-white bg-gray-800 hover:bg-gray-700 rounded-full p-1 transition"
        title="Hide Ads"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <a
          v-for="ad in ads"
          :key="ad.id"
          :href="ad.external_url || '#'"
          target="_blank"
          rel="noopener noreferrer"
          class="relative group bg-gray-800 border border-gray-600 rounded-xl overflow-hidden shadow-lg hover:shadow-[0_0_20px_rgba(234,179,8,0.4)] hover:border-yellow-500 transition-all duration-300 transform hover:-translate-y-1 block"
      >
        <div class="relative h-32 overflow-hidden">
          <img
              v-if="ad.image_url"
              :src="ad.image_url"
              alt="Offer"
              class="w-full h-full object-cover transform group-hover:scale-110 transition duration-700"
          />
          <div class="absolute inset-0 bg-gradient-to-t from-gray-900 via-gray-900/40 to-transparent"></div>
          
          <!-- Badge -->
          <div class="absolute top-2 right-2">
             <span class="text-[10px] font-bold bg-black/60 text-white/70 px-2 py-0.5 rounded border border-white/10 uppercase tracking-tighter">
               Sponsored
            </span>
          </div>
        </div>
        
        <div class="p-3">
          <div class="flex justify-between items-start mb-1">
            <h4 class="text-md font-bold text-gray-100 group-hover:text-yellow-400 transition">{{ ad.title }}</h4>
            <span class="text-yellow-500 group-hover:translate-x-1 transition-transform">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
              </svg>
            </span>
          </div>
          <p class="text-xs text-gray-400 leading-relaxed line-clamp-2">{{ ad.description }}</p>
        </div>
      </a>
    </div>
  </div>
</template>
