// Global Fetch API Handler and Helper Functions
const API_BASE_URL = '/api';

/**
 * Perform an HTTP Request to the Express API with JWT validation
 * @param {string} endpoint - API path (e.g. '/login', '/slots')
 * @param {string} method - HTTP Verb (GET, POST, PUT, DELETE)
 * @param {object} body - Request payload (optional)
 * @returns {Promise<object>} JSON response
 */
async function apiRequest(endpoint, method = 'GET', body = null) {
  const url = `${API_BASE_URL}${endpoint}`;
  
  // Prepare headers
  const headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  // Retrieve token from localStorage
  const token = localStorage.getItem('parking_jwt_token');
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const options = {
    method,
    headers
  };

  if (body && (method === 'POST' || method === 'PUT')) {
    options.body = JSON.stringify(body);
  }

  try {
    const response = await fetch(url, options);
    
    // Check for authorization expired or revoked
    if (response.status === 401 || response.status === 403) {
      // Don't auto-redirect on login fail, only on authenticated routes failing
      if (endpoint !== '/login') {
        showToast('Session expired. Please log in again.', 'error');
        localStorage.removeItem('parking_jwt_token');
        localStorage.removeItem('parking_user');
        setTimeout(() => {
          window.location.href = 'login.html';
        }, 1500);
        throw new Error('Unauthorized');
      }
    }

    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.message || `HTTP error! Status: ${response.status}`);
    }

    return data;
  } catch (error) {
    console.error(`API Request [${method}] ${endpoint} failed:`, error);
    throw error;
  }
}

/**
 * Display toast notification dynamically
 * @param {string} message - Text notification
 * @param {string} type - 'success', 'error', 'warning'
 */
function showToast(message, type = 'success') {
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    document.body.appendChild(container);
  }

  const toast = document.createElement('div');
  toast.className = `custom-toast ${type}`;
  
  let icon = 'fa-check-circle';
  if (type === 'error') icon = 'fa-times-circle';
  if (type === 'warning') icon = 'fa-exclamation-triangle';

  toast.innerHTML = `
    <i class="fas ${icon} fa-lg"></i>
    <div style="flex-grow:1;">${message}</div>
    <button onclick="this.parentElement.remove()" style="background:none; border:none; color:white; opacity:0.6; cursor:pointer;">
      <i class="fas fa-times"></i>
    </button>
  `;

  container.appendChild(toast);

  // Auto remove
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(20px)';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

/**
 * Show a simple premium loader spinner inside a DOM element
 * @param {HTMLElement} element - Target container
 */
function showLoader(element) {
  element.innerHTML = `
    <div class="spinner-wrapper">
      <div class="custom-spinner"></div>
    </div>
  `;
}
