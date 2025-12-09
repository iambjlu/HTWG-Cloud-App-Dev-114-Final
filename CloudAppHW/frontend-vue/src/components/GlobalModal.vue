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
    <div class="global-modal-container">
      <!-- Title -->
      <h3 class="text-lg font-semibold text-gray-900 mb-2">{{ modalState.title }}</h3>
      
      <!-- Message -->
      <p class="text-sm text-gray-600 mb-6 whitespace-pre-wrap leading-relaxed">{{ modalState.message }}</p>
      
      <!-- Buttons -->
      <div class="flex justify-end space-x-3">
        <button 
          v-if="modalState.type === 'confirm'"
          @click="handleCancel"
          class="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition text-sm font-medium focus:outline-none focus:ring-2 focus:ring-gray-300"
        >
          {{ modalState.cancelText }}
        </button>
        
        <button 
          @click="handleConfirm"
          class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition text-sm font-medium focus:outline-none focus:ring-2 focus:ring-indigo-500 shadow-md transform hover:scale-105"
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
  z-index: 10000; /* Higher than isLoading (9998) and Header (9999) */
  background-color: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.2s ease-out;
}

.global-modal-container {
  background-color: white;
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
