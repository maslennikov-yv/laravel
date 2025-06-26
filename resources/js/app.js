import './bootstrap';

// Laravel application initialization
document.addEventListener('DOMContentLoaded', function () {
  // Initialize Alpine.js components
  if (window.Alpine) {
    window.Alpine.start();
  }

  // Example function with proper formatting
  const initializeApp = () => {
    const appElement = document.getElementById('app');

    if (appElement) {
      appElement.classList.add('loaded');
    }
  };

  // Call initialization
  initializeApp();
});

// Example Vue component (if using Vue)
if (typeof Vue !== 'undefined') {
  const app = Vue.createApp({
    data() {
      return {
        message: 'Hello Laravel!',
      };
    },
    methods: {
      updateMessage(newMessage) {
        this.message = newMessage;
      },
    },
  });

  app.mount('#app');
}

// Export for module usage
export default {
  name: 'LaravelApp',
  version: '1.0.0',
};
// Test comment
