<script setup>
import { modalState, closeModal } from '../utils/modal.js';

function handleConfirm() {
  if (modalState.onConfirm) {
    modalState.onConfirm();
  }
  closeModal();
}

function handleCancel() {
  if (modalState.onCancel) {
    modalState.onCancel();
  }
  closeModal();
}
</script>

<template>
  <div v-if="modalState.visible" class="global-modal-overlay">
    <div class="global-modal-container border border-gray-700">
      <!-- Title -->
      <h3 class="text-lg font-semibold text-white mb-2">{{ modalState.title }}</h3>
      
      <!-- Message -->
      <div class="text-sm text-gray-300 mb-6 leading-relaxed" v-html="modalState.message"></div>
      
      <!-- Buttons -->
      <div class="flex justify-end space-x-3">
        <button 
          v-if="modalState.type === 'confirm'"
          @click="handleCancel"
          class="px-4 py-2 bg-gray-800 border-2 border-gray-500 text-gray-300 rounded-lg hover:bg-gray-700 transition text-sm font-bold focus:outline-none focus:ring-2 focus:ring-gray-500 shadow-[0_0_10px_rgba(156,163,175,0.5)]"
        >
          {{ modalState.cancelText }}
        </button>
        
        <button 
          @click="handleConfirm"
          class="px-4 py-2 bg-gray-800 border-2 border-cyan-500 text-cyan-500 rounded-lg hover:bg-gray-700 transition text-sm font-bold focus:outline-none focus:ring-2 focus:ring-cyan-500 shadow-[0_0_10px_rgba(6,182,212,0.5)] transform hover:scale-105"
        >
          {{ modalState.confirmText }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.global-modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 99999; /* Highest layer, above all other modals */
  background-color: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.2s ease-out;
}

.global-modal-container {
  background-color: #1f2937; /* gray-800 */
  width: 90%;
  max-width: 400px;
  border-radius: 16px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  padding: 1.5rem;
  transform: scale(1);
  animation: popIn 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes popIn {
  from { transform: scale(0.95); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}
</style>
