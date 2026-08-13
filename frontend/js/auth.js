// Authentication and Page Guard utilities

document.addEventListener('DOMContentLoaded', () => {
  checkAuthAndInitialize();
});

/**
 * Validates token presence, controls routing protection, and injects templates
 */
function checkAuthAndInitialize() {
  const token = localStorage.getItem('parking_jwt_token');
  const user = JSON.parse(localStorage.getItem('parking_user') || 'null');
  
  const currentPage = window.location.pathname.split('/').pop();

  // 1. Route Safeguards
  if (!token || !user) {
    if (currentPage !== 'login.html' && currentPage !== 'index.html' && currentPage !== '') {
      window.location.href = 'login.html';
      return;
    }
  } else {
    // Already logged in, redirect away from login/index to dashboard
    if (currentPage === 'login.html' || currentPage === 'index.html' || currentPage === '') {
      window.location.href = 'dashboard.html';
      return;
    }

    // Role-based restrict (Attendants cannot view attendants/areas pages)
    if (user.role !== 'Admin') {
      const adminOnlyPages = ['attendants.html', 'areas.html'];
      if (adminOnlyPages.includes(currentPage)) {
        alert('Access denied. Administrator privileges required.');
        window.location.href = 'dashboard.html';
        return;
      }
    }
  }

  // 2. Inject Sidebar & Header if element containers exist
  if (token && user) {
    injectSidebar(user, currentPage);
    injectTopbar(user);
    setupMobileToggle();
  }
}

/**
 * Injects unified sidebar menu tailored to roles
 */
function injectSidebar(user, currentPage) {
  const container = document.getElementById('sidebar-container');
  if (!container) return;

  container.className = 'sidebar';

  // Define sidebar menu entries based on role
  const menuItems = [
    { name: 'Dashboard', icon: 'fa-chart-pie', link: 'dashboard.html', roles: ['Admin', 'Attendant'] },
    { name: 'Check-in (Entry)', icon: 'fa-sign-in-alt', link: 'entry.html', roles: ['Admin', 'Attendant'] },
    { name: 'Check-out (Exit)', icon: 'fa-sign-out-alt', link: 'exit.html', roles: ['Admin', 'Attendant'] },
    { name: 'Parking Slots', icon: 'fa-parking', link: 'slots.html', roles: ['Admin', 'Attendant'] },
    { name: 'Vehicles', icon: 'fa-car', link: 'vehicles.html', roles: ['Admin', 'Attendant'] },
    { name: 'Parking Records', icon: 'fa-history', link: 'records.html', roles: ['Admin', 'Attendant'] },
    { name: 'Payments', icon: 'fa-receipt', link: 'payments.html', roles: ['Admin', 'Attendant'] },
    { name: 'Areas & Rates', icon: 'fa-map-marked-alt', link: 'areas.html', roles: ['Admin'] },
    { name: 'Attendants', icon: 'fa-users-cog', link: 'attendants.html', roles: ['Admin'] }
  ];

  let menuHtml = '';
  menuItems.forEach(item => {
    if (item.roles.includes(user.role)) {
      const activeClass = currentPage === item.link ? 'active' : '';
      menuHtml += `
        <li>
          <a href="${item.link}" class="nav-item-link ${activeClass}">
            <i class="fas ${item.icon} fa-fw"></i>
            <span>${item.name}</span>
          </a>
        </li>
      `;
    }
  });

  const initials = user.name ? user.name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2) : 'U';

  container.innerHTML = `
    <a href="dashboard.html" class="sidebar-brand">
      <i class="fas fa-parking"></i>
      <span>SmartPark Pro</span>
    </a>
    
    <ul class="nav-menu">
      ${menuHtml}
    </ul>
    
    <div class="sidebar-footer">
      <div class="user-profile-badge">
        <div class="user-avatar">${initials}</div>
        <div class="user-info">
          <span class="user-name" title="${user.name}">${user.name}</span>
          <span class="user-role">${user.role}</span>
        </div>
      </div>
      <a href="#" onclick="processLogout(event)" class="nav-item-link text-danger border border-danger-subtle bg-danger-subtle bg-opacity-10 text-center py-2 justify-content-center">
        <i class="fas fa-power-off"></i>
        <span>Logout</span>
      </a>
    </div>
  `;
}

/**
 * Injects top navigation bar
 */
function injectTopbar(user) {
  const container = document.getElementById('topbar-container');
  if (!container) return;

  container.className = 'topbar';
  
  const pageName = document.title || 'Smart Parking';

  container.innerHTML = `
    <div class="d-flex align-items-center gap-3">
      <button class="topbar-toggle" id="sidebar-toggle-btn">
        <i class="fas fa-bars"></i>
      </button>
      <div class="page-title-sec">
        <h1>${pageName}</h1>
      </div>
    </div>
    <div class="d-flex align-items-center gap-3">
      <span class="badge bg-opacity-10 bg-info text-info border border-info border-opacity-25 px-3 py-2">
        <i class="fas fa-clock me-1"></i> <span id="live-time-ticker">--:--:--</span>
      </span>
      <span class="badge bg-opacity-10 bg-success text-success border border-success border-opacity-25 px-3 py-2">
        <i class="fas fa-shield-alt me-1"></i> Secure JWT
      </span>
    </div>
  `;

  // Start live clock ticker
  setInterval(() => {
    const clock = document.getElementById('live-time-ticker');
    if (clock) {
      const now = new Date();
      clock.innerText = now.toLocaleTimeString();
    }
  }, 1000);
}

/**
 * Handle mobile navigation menus toggling
 */
function setupMobileToggle() {
  setTimeout(() => {
    const toggleBtn = document.getElementById('sidebar-toggle-btn');
    const sidebar = document.getElementById('sidebar-container');
    
    if (toggleBtn && sidebar) {
      toggleBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        sidebar.classList.toggle('active');
      });

      // Click outside to close on mobile
      document.addEventListener('click', (e) => {
        if (window.innerWidth <= 991.98 && sidebar.classList.contains('active')) {
          if (!sidebar.contains(e.target) && e.target !== toggleBtn) {
            sidebar.classList.remove('active');
          }
        }
      });
    }
  }, 300);
}

/**
 * Process system logouts
 */
function processLogout(e) {
  if (e) e.preventDefault();
  if (confirm('Are you sure you want to log out?')) {
    localStorage.removeItem('parking_jwt_token');
    localStorage.removeItem('parking_user');
    window.location.href = 'login.html';
  }
}
