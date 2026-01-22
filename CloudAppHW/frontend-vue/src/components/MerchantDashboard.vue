<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { showModal } from '../utils/modal.js';

// Use same env logic as AdBanner
const AD_SERVICE_URL = import.meta.env.VITE_AD_SERVICE_URL || '/api/ads';

const ads = ref([]);
const loading = ref(false);
const isEditing = ref(false);
const showForm = ref(false);

const form = ref({
  id: null,
  destination: '',
  title: '',
  description: '',
  external_url: '',
  image_url: ''
});

async function fetchAds() {
  loading.value = true;
  try {
    const res = await axios.get(AD_SERVICE_URL); // Get all
    ads.value = res.data || [];
  } catch (err) {
    console.error('Failed to load ads', err);
    showModal({ title: 'Error', message: 'Failed to load ads from: ' + AD_SERVICE_URL, type: 'alert' });
  } finally {
    loading.value = false;
  }
}

function openCreate() {
  form.value = { id: null, destination: '', title: '', description: '', external_url: '', image_url: '' };
  isEditing.value = false;
  showForm.value = true;
}

function openEdit(ad) {
  form.value = { ...ad };
  isEditing.value = true;
  showForm.value = true;
}

function closeForm() {
  showForm.value = false;
}

async function submitForm() {
  if (!form.value.destination || !form.value.title) {
    alert('Destination and Title are required');
    return;
  }
  
  try {
    if (isEditing.value) {
      await axios.put(`${AD_SERVICE_URL}/${form.value.id}`, form.value);
      showModal({ title: 'Success', message: 'Ad updated successfully!', type: 'alert' });
    } else {
      await axios.post(AD_SERVICE_URL, form.value);
      showModal({ title: 'Success', message: 'Ad created successfully!', type: 'alert' });
    }
    closeForm();
    await fetchAds();
  } catch (err) {
    console.error('Save failed', err);
    showModal({ title: 'Error', message: 'Failed to save ad.', type: 'alert' });
  }
}

async function deleteAd(id) {
  if(!confirm('Are you sure you want to delete this ad?')) return;
  try {
    await axios.delete(`${AD_SERVICE_URL}/${id}`);
    await fetchAds();
  } catch (err) {
    console.error('Delete failed', err);
    showModal({ title: 'Error', message: 'Failed to delete ad.', type: 'alert' });
  }
}

onMounted(() => {
  fetchAds();
});
</script>

<template>
  <div class="bg-gray-900 min-h-screen text-white p-6">
    <div class="max-w-6xl mx-auto">
      <header class="flex justify-between items-center mb-8 border-b border-gray-700 pb-4">
        <div>
          <h1 class="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-yellow-400 to-orange-500">
            Merchant Portal
          </h1>
          <p class="text-gray-400 text-sm mt-1">Manage external sponsored links</p>
        </div>
        <div class="flex gap-3">
          <a href="/" class="bg-gray-800 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded border border-gray-600 transition">
            Back to App
          </a>
          <button 
            @click="openCreate"
            class="bg-blue-600 hover:bg-blue-500 text-white font-bold py-2 px-4 rounded shadow-lg transition transform hover:scale-105"
          >
            + Create New Ad
          </button>
        </div>
      </header>
      
      <!-- List -->
      <div v-if="loading" class="text-center py-10 text-gray-400 italic">
        Syncing with Ad Service...
      </div>
      
      <div v-else-if="ads.length === 0" class="text-center py-20 bg-gray-800/20 rounded-2xl border-2 border-dashed border-gray-700">
        <p class="text-gray-500">No sponsored links yet.</p>
        <button @click="openCreate" class="mt-4 text-blue-400 hover:underline">Register your first advertisement</button>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="ad in ads" :key="ad.id" class="bg-gray-800 rounded-xl overflow-hidden shadow-lg border border-gray-700 group flex flex-col">
          <div class="h-40 overflow-hidden relative">
            <img :src="ad.image_url || 'https://via.placeholder.com/400x200?text=No+Image'" class="w-full h-full object-cover group-hover:scale-110 transition duration-500"/>
            <div class="absolute top-2 right-2 bg-black/70 px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider text-gray-300">
              {{ ad.destination }}
            </div>
          </div>
          <div class="p-4 flex-grow flex flex-col">
            <h3 class="font-bold text-lg mb-1 truncate text-gray-100">{{ ad.title }}</h3>
            <p class="text-gray-400 text-xs line-clamp-2 h-8 mb-4">{{ ad.description }}</p>
            
            <div class="mt-auto border-t border-gray-700 pt-3">
              <div class="flex items-center gap-1 text-blue-400 text-[10px] mb-3 bg-blue-900/20 p-2 rounded truncate border border-blue-900/30">
                <span class="flex-shrink-0">🔗</span>
                <span class="truncate">{{ ad.external_url || 'No External Link Set' }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-[10px] text-gray-500 font-bold uppercase tracking-widest">Active</span>
                <div class="flex gap-3">
                  <button @click="openEdit(ad)" class="text-gray-400 hover:text-white text-xs font-bold transition">EDIT</button>
                  <button @click="deleteAd(ad.id)" class="text-red-900 hover:text-red-500 text-xs font-bold transition">DELETE</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Modal Form -->
      <div v-if="showForm" class="fixed inset-0 bg-black/90 backdrop-blur-sm flex items-center justify-center z-50 p-4">
        <div class="bg-gray-800 rounded-2xl w-full max-w-lg overflow-hidden shadow-2xl border border-gray-700 transform transition-all">
          <div class="bg-gradient-to-r from-blue-900 to-indigo-900 p-6">
            <h2 class="text-2xl font-bold text-white">{{ isEditing ? 'Update Advertisement' : 'Register Advertisement' }}</h2>
            <p class="text-blue-200 text-xs mt-1">This link will appear as a sponsored suggestion in itineraries.</p>
          </div>
          
          <div class="p-8 space-y-5">
            <div class="grid grid-cols-2 gap-4">
               <div>
                <label class="block text-[10px] font-bold text-gray-500 uppercase tracking-widest mb-1">Target Destination</label>
                <input v-model="form.destination" type="text" placeholder="e.g. Kyoto" class="w-full bg-gray-900 border border-gray-700 rounded-lg p-3 text-white focus:ring-2 focus:ring-blue-500 focus:outline-none transition"/>
              </div>
              <div>
                <label class="block text-[10px] font-bold text-gray-500 uppercase tracking-widest mb-1">Display Title</label>
                <input v-model="form.title" type="text" placeholder="Merchant Name / Deal" class="w-full bg-gray-900 border border-gray-700 rounded-lg p-3 text-white focus:ring-2 focus:ring-blue-500 focus:outline-none transition"/>
              </div>
            </div>
            
             <div>
              <label class="block text-[10px] font-bold text-gray-500 uppercase tracking-widest mb-1">Brief Description</label>
              <textarea v-model="form.description" rows="2" placeholder="Describe the offer or destination appeal..." class="w-full bg-gray-900 border border-gray-700 rounded-lg p-3 text-white focus:ring-2 focus:ring-blue-500 focus:outline-none transition"></textarea>
            </div>

            <div>
              <label class="block text-[10px] font-bold text-gray-500 uppercase tracking-widest mb-1">External Link (Redirect URL)</label>
              <input v-model="form.external_url" type="url" placeholder="https://example.com/booking" class="w-full bg-gray-900 border border-gray-700 rounded-lg p-3 text-white focus:ring-2 focus:ring-blue-500 focus:outline-none transition font-mono text-xs"/>
            </div>
            
             <div>
              <label class="block text-[10px] font-bold text-gray-500 uppercase tracking-widest mb-1">Cover Image URL</label>
              <input v-model="form.image_url" type="text" placeholder="https://unsplash.com/..." class="w-full bg-gray-900 border border-gray-700 rounded-lg p-3 text-white focus:ring-2 focus:ring-blue-500 focus:outline-none transition font-mono text-xs"/>
            </div>
          </div>
          
          <div class="bg-gray-900/50 p-6 px-8 flex justify-end gap-3 border-t border-gray-700/50">
            <button @click="closeForm" class="px-6 py-2 rounded-lg text-gray-400 hover:text-white transition font-bold text-sm">CANCEL</button>
            <button @click="submitForm" class="px-8 py-2 rounded-lg bg-blue-600 hover:bg-blue-500 text-white font-bold transition shadow-lg text-sm uppercase tracking-wider">
              {{ isEditing ? 'Save Changes' : 'Launch Ad' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
