import { reactive } from 'vue';

export const modalState = reactive({
    visible: false,
    title: '',
    message: '',
    type: 'alert', // 'alert' | 'confirm'
    confirmText: 'OK',
    cancelText: 'Cancel',
    onConfirm: null,
    onCancel: null
});

export function showModal({
    title = 'Notification',
    message = '',
    type = 'alert',
    confirmText = 'OK',
    cancelText = 'Cancel',
    onConfirm = null,
    onCancel = null
}) {
    modalState.title = title;
    modalState.message = message;
    modalState.type = type;
    modalState.confirmText = confirmText;
    modalState.cancelText = cancelText;
    modalState.onConfirm = onConfirm;
    modalState.onCancel = onCancel;
    modalState.visible = true;
}

export function closeModal() {
    modalState.visible = false;
    // Reset slightly later to avoid flickering during transition if any
    setTimeout(() => {
        modalState.onConfirm = null;
        modalState.onCancel = null;
    }, 200);
}
