// Dashboard Dynamic Interaction Controller

document.addEventListener('DOMContentLoaded', () => {
  // Let checkAuthAndInitialize boot first, then load statistics
  setTimeout(() => {
    loadDashboardData();
    setupDashboardListeners();
  }, 400);
});

function setupDashboardListeners() {
  const areaFilter = document.getElementById('dashboard-area-filter');
  if (areaFilter) {
    areaFilter.addEventListener('change', () => {
      loadSlotsGrid(areaFilter.value);
    });
  }
}

/**
 * Perform asynchronous fetches for stats, areas, slots and recent logs
 */
async function loadDashboardData() {
  const user = JSON.parse(localStorage.getItem('parking_user') || '{}');
  
  // Show extended panel if user is Admin
  const adminRow = document.getElementById('admin-extended-row');
  if (user.role === 'Admin' && adminRow) {
    adminRow.classList.remove('d-none');
  }

  try {
    // 1. Fetch system metrics
    const statsResponse = await apiRequest('/dashboard/stats');
    if (statsResponse.success) {
      renderStats(statsResponse.data, user.role);
    }

    // 2. Fetch areas to build dropdown filter
    const areasResponse = await apiRequest('/areas');
    if (areasResponse.success) {
      populateAreaFilter(areasResponse.data);
    }

    // 3. Load Slots Grid
    const selectedAreaId = document.getElementById('dashboard-area-filter')?.value || '';
    await loadSlotsGrid(selectedAreaId);

  } catch (err) {
    console.error('Failed to load dashboard data:', err);
    showToast('Failed to connect to API server. Verify Node server status.', 'error');
  }
}

/**
 * Bind dashboard figures into DOM indicators
 */
function renderStats(data, role) {
  // Common indicators
  document.getElementById('stat-available-slots').innerText = data.slots.available;
  document.getElementById('stat-occupied-slots').innerText = data.slots.occupied;
  document.getElementById('stat-total-slots').innerText = data.slots.total;
  document.getElementById('stat-today-revenue').innerText = `₹${data.revenue.today}`;

  // Admin exclusive indicators
  if (role === 'Admin') {
    const totalVehiclesEl = document.getElementById('stat-total-vehicles');
    const activeSessionsEl = document.getElementById('stat-active-sessions');
    const monthlyRevenueEl = document.getElementById('stat-monthly-revenue');
    const maintenanceSlotsEl = document.getElementById('stat-maintenance-slots');

    if (totalVehiclesEl) totalVehiclesEl.innerText = data.total_vehicles;
    if (activeSessionsEl) activeSessionsEl.innerText = data.active_sessions;
    if (monthlyRevenueEl) monthlyRevenueEl.innerText = `₹${data.revenue.monthly}`;
    if (maintenanceSlotsEl) maintenanceSlotsEl.innerText = data.slots.maintenance;
  }

  // Render recent transactions feed
  renderTransactions(data.recent_transactions);
}

/**
 * Builds dropdown selections for areas
 */
function populateAreaFilter(areas) {
  const filter = document.getElementById('dashboard-area-filter');
  if (!filter) return;

  // Save current selection value
  const currentValue = filter.value;
  
  // Clear and keep default
  filter.innerHTML = '<option value="">All Parking Areas</option>';
  
  areas.forEach(area => {
    filter.innerHTML += `<option value="${area.id}">${area.name} (₹${area.base_price}/hr)</option>`;
  });

  // Restore previous value if applicable
  filter.value = currentValue;
}

/**
 * Fetch and construct slot maps
 */
async function loadSlotsGrid(areaId = '') {
  const container = document.getElementById('slots-grid-container');
  const loader = document.getElementById('slots-loader-container');
  if (!container) return;

  showLoader(loader);
  container.innerHTML = '';

  try {
    let endpoint = '/slots';
    if (areaId) endpoint += `?area_id=${areaId}`;

    const response = await apiRequest(endpoint);
    loader.innerHTML = '';

    if (response.success && response.data.length > 0) {
      response.data.forEach(slot => {
        const slotEl = document.createElement('div');
        slotEl.className = `slot-item ${slot.status}`;
        
        let typeIcon = 'fa-car';
        if (slot.type === 'Two-Wheeler') typeIcon = 'fa-motorcycle';
        if (slot.type === 'Heavy-Vehicle') typeIcon = 'fa-truck-monster';

        let badgeClass = 'badge-available';
        if (slot.status === 'Occupied') badgeClass = 'badge-occupied';
        if (slot.status === 'Maintenance') badgeClass = 'badge-maintenance';

        slotEl.innerHTML = `
          <div class="slot-number">${slot.slot_number}</div>
          <div class="slot-type mb-2">
            <i class="fas ${typeIcon}"></i>
            <span>${slot.type}</span>
          </div>
          <span class="badge-status ${badgeClass}" style="font-size:0.65rem;">${slot.status}</span>
        `;

        // Click handler: smart navigation based on status
        slotEl.addEventListener('click', () => {
          if (slot.status === 'Available') {
            window.location.href = `entry.html?slot_id=${slot.id}&slot_number=${slot.slot_number}`;
          } else if (slot.status === 'Occupied') {
            window.location.href = `exit.html?slot_id=${slot.id}&slot_number=${slot.slot_number}`;
          } else {
            showToast(`Slot ${slot.slot_number} is under Maintenance.`, 'warning');
          }
        });

        container.appendChild(slotEl);
      });
    } else {
      container.innerHTML = `
        <div class="col-12 text-center text-secondary py-5">
          <i class="fas fa-parking fa-3x mb-3 text-muted"></i>
          <p>No parking slots defined yet. Go to Areas/Slots configuration to add.</p>
        </div>
      `;
    }
  } catch (err) {
    console.error(err);
    loader.innerHTML = '';
    container.innerHTML = `<div class="text-danger">Failed to load slots map.</div>`;
  }
}

/**
 * Renders transaction rows into side panels
 */
function renderTransactions(txns) {
  const container = document.getElementById('recent-transactions-container');
  if (!container) return;

  if (txns && txns.length > 0) {
    container.innerHTML = '';
    txns.forEach(txn => {
      const date = new Date(txn.payment_date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      
      let methodIcon = 'fa-money-bill-wave text-success';
      if (txn.payment_method === 'UPI') methodIcon = 'fa-mobile-alt text-info';
      if (txn.payment_method === 'Card') methodIcon = 'fa-credit-card text-warning';

      container.innerHTML += `
        <div class="glass-panel p-3 d-flex align-items-center justify-content-between" style="background: rgba(255,255,255,0.01)">
          <div class="d-flex align-items-center gap-3">
            <div class="rounded-circle bg-dark d-flex align-items-center justify-content-center" style="width: 40px; height: 40px; border: 1px solid var(--border-color);">
              <i class="fas ${methodIcon}"></i>
            </div>
            <div>
              <div class="fw-bold" style="font-size:0.9rem;">${txn.license_plate}</div>
              <div class="text-muted small" style="font-size:0.75rem;">${txn.area_name} • ${txn.payment_method}</div>
            </div>
          </div>
          <div class="text-end">
            <div class="fw-bold text-success" style="font-size:0.95rem;">+₹${txn.amount}</div>
            <div class="text-muted small" style="font-size:0.75rem;">${date}</div>
          </div>
        </div>
      `;
    });
  } else {
    container.innerHTML = `
      <div class="text-center text-secondary py-5">
        <p class="mb-0">No transaction logs recorded today.</p>
      </div>
    `;
  }
}
