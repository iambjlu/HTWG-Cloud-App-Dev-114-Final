<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { auth } from '../firebase';

const emit = defineEmits(['close']);

const users = ref([]);
const message = ref('');
const loading = ref(false);

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

const fetchUsers = async () => {
    loading.value = true;
    try {
        // Ensure token
        const token = await auth.currentUser?.getIdToken();
        if(token) axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

        const res = await axios.get(`${API_BASE_URL}/api/admin/users`);
        users.value = res.data;
    } catch (e) {
        console.error(e);
        message.value = 'Failed to load users: ' + (e.response?.data?.message || e.message);
    } finally {
        loading.value = false;
    }
};

const updateUserLevel = async (user, newLevel) => {
    const originalLevel = user.membership_tier;
    user.membership_tier = newLevel; // Optimistic update
    try {
        await axios.put(`${API_BASE_URL}/api/admin/users/${user.id}/level`, { level: newLevel });
        message.value = `Updated ${user.email} to ${newLevel}`;
        setTimeout(() => message.value = '', 3000);
    } catch (e) {
        user.membership_tier = originalLevel; // Revert
        alert('Update failed: ' + (e.response?.data?.message || e.message));
    }
};

onMounted(() => {
    fetchUsers();
});
</script>

<template>
  <div class="space-y-6">
      <div class="bg-gray-900 p-6 rounded-xl shadow-lg border border-red-900">
        <div class="flex justify-between items-center mb-4 border-b border-gray-700 pb-2">
            <h2 class="text-xl font-semibold text-red-400">🛡️ Admin Portal</h2>
            <div class="flex space-x-2">
                <button @click="fetchUsers" class="text-sm bg-gray-800 px-3 py-1 rounded hover:bg-gray-700">Refresh</button>
                <button @click="$emit('close')" class="text-sm bg-red-900 px-3 py-1 rounded hover:bg-red-800 text-white">Exit</button>
            </div>
        </div>

        <div v-if="loading" class="text-center text-gray-400">Loading users...</div>
        
        <div v-else class="overflow-x-auto">
            <table class="w-full text-left text-gray-300 text-sm">
                <thead class="bg-gray-800 text-gray-400 uppercase text-xs">
                    <tr>
                        <th class="px-4 py-3">ID</th>
                        <th class="px-4 py-3">Name</th>
                        <th class="px-4 py-3">Email</th>
                        <th class="px-4 py-3">Tier</th>
                        <th class="px-4 py-3">Admin</th>
                        <th class="px-4 py-3">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-700">
                    <tr v-for="user in users" :key="user.id" class="hover:bg-gray-800/50">
                        <td class="px-4 py-3">{{ user.id }}</td>
                        <td class="px-4 py-3">{{ user.name }}</td>
                        <td class="px-4 py-3">{{ user.email }}</td>
                        <td class="px-4 py-3">
                            <span 
                                class="px-2 py-1 rounded text-xs font-bold"
                                :class="user.membership_tier === 'Premium' ? 'bg-yellow-900 text-yellow-200' : 'bg-gray-700 text-gray-300'"
                            >
                                {{ user.membership_tier || 'Free' }}
                            </span>
                        </td>
                        <td class="px-4 py-3">
                            <span v-if="user.is_admin" class="text-red-400 font-bold">YES</span>
                            <span v-else class="text-gray-600">-</span>
                        </td>
                        <td class="px-4 py-3 flex space-x-2">
                            <button 
                                v-if="user.membership_tier !== 'Premium'"
                                @click="updateUserLevel(user, 'Premium')"
                                class="bg-yellow-700 hover:bg-yellow-600 text-white px-2 py-1 rounded text-xs"
                            >
                                Set Premium
                            </button>
                            <button 
                                v-if="user.membership_tier === 'Premium'"
                                @click="updateUserLevel(user, 'Free')"
                                class="bg-gray-600 hover:bg-gray-500 text-white px-2 py-1 rounded text-xs"
                            >
                                Set Free
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <p v-if="message" class="mt-2 text-green-400 text-sm animate-pulse">{{ message }}</p>
        <br>
        <a href="/?panel=merchant" class="text-[9px] text-white/40 hover:text-white uppercase tracking-widest transition-colors mr-0.5">
             Merchant Entrance
          </a>
      </div>
  </div>
</template>
