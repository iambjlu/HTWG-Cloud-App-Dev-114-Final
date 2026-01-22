<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import AdBanner from './AdBanner.vue';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

const feedItems = ref([]);
const loading = ref(false);
const error = ref('');

const props = defineProps(['currentUserEmail', 'membershipTier']);

async function fetchFeed() {
  loading.value = true;
  error.value = '';
  try {
    const res = await axios.get(`${API_BASE_URL}/api/itineraries/feed`);
    feedItems.value = res.data || [];
  } catch(e) {
    console.error(e);
    error.value = 'Failed to load feed.';
  } finally {
    loading.value = false;
  }
}

function formatDate(ds) {
  if(!ds) return '';
  return new Date(ds).toLocaleDateString();
}

onMounted(() => {
  fetchFeed();
});
</script>

<template>
  <div class="space-y-6">
    <!-- General Ad Banner -->
    <AdBanner :membership-tier="props.membershipTier || 'Free'" />

    <!-- Header -->
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-cyan-400 to-purple-500">
        ✨ Explore Itineraries
      </h2>
      <button 
        @click="fetchFeed" 
        class="text-sm text-gray-400 hover:text-white transition flex items-center bg-gray-800 px-3 py-1 rounded-full border border-gray-700 hover:border-cyan-500"
      >
        <span class="mr-1">🔄</span> Refresh
      </button>
    </div>

    <!-- Error/Loading -->
    <div v-if="loading" class="text-center py-10">
      <div class="text-cyan-400 animate-pulse text-lg font-bold">Loading recommendations...</div>
    </div>
    <div v-if="error" class="text-center py-10 text-red-500">{{ error }}</div>

    <!-- Masonry/Grid Layout -->
    <div v-if="!loading && !error" class="grid grid-cols-1 md:grid-cols-2 gap-6">
      
      <!-- Card -->
      <a 
        v-for="item in feedItems" 
        :key="item.id"
        :href="`/?profile=${item.traveller_email}&trip=${item.id}`"
        class="group relative bg-gray-900 border border-gray-700 rounded-xl overflow-hidden hover:border-cyan-500 transition-all duration-300 hover:shadow-[0_0_20px_rgba(6,182,212,0.3)] shadow-lg flex flex-col block cursor-pointer"
      >
        
        <!-- Decoration Gradient -->
        <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-cyan-500 via-purple-500 to-pink-500 opacity-70 group-hover:opacity-100 transition-opacity"></div>
        
        <div class="p-5 flex-grow flex flex-col">
          <!-- Meta (Dates) -->
          <div class="text-xs font-bold text-gray-500 uppercase tracking-widest mb-1 flex justify-between">
            <span>{{ item.destination }}</span>
            <span class="text-cyan-600">{{ formatDate(item.start_date) }}</span>
          </div>

          <!-- Title -->
          <h3 class="text-xl font-bold text-white mb-2 group-hover:text-cyan-400 transition-colors">
            {{ item.title }}
          </h3>

          <!-- Description -->
          <p class="text-sm text-gray-400 mb-4 line-clamp-3 leading-relaxed">
            {{ item.short_description || 'No description provided.' }}
          </p>
          
          <div class="mt-auto flex items-center justify-between border-t border-gray-800 pt-3">
             <!-- User Info -->
             <div class="flex items-center space-x-2">
               <div class="w-6 h-6 rounded-full bg-gradient-to-tr from-cyan-600 to-blue-800 flex items-center justify-center text-[10px] text-white font-bold">
                  {{ (item.traveller_name || 'U').charAt(0).toUpperCase() }}
               </div>
               <span class="text-xs text-gray-400 group-hover:text-white truncate max-w-[120px]">
                 {{ item.traveller_name || item.traveller_email }}
               </span>
             </div>
             
             <!-- Action Hint (Arrow) -->
             <span class="text-xs text-cyan-500 group-hover:translate-x-1 transition-transform">
               View &rarr;
             </span>
          </div>
        </div>
      </a>
    
    </div>

    <div v-if="!loading && feedItems?.length === 0" class="text-center text-gray-500 italic py-10">
       No itineraries found. Be the first to create one!
    </div>

  </div>
</template>
