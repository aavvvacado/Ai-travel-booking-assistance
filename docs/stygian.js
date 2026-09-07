/* Stygian Interactive Documentation Engine */
document.addEventListener('DOMContentLoaded', () => {
  // 1. Pre-paint theme boot / toggle
  const themeToggleBtn = document.getElementById('themeToggleBtn');
  const themeIcon = document.getElementById('themeIcon');
  const themeText = document.getElementById('themeText');

  const getSavedTheme = () => {
    try {
      return localStorage.getItem('stygian-theme') || 'dark';
    } catch (_) {
      return 'dark';
    }
  };

  const applyTheme = (theme) => {
    document.documentElement.setAttribute('data-theme', theme);
    if (themeIcon && themeText) {
      if (theme === 'dark') {
        themeIcon.textContent = '🌙';
        themeText.textContent = 'Dark';
      } else {
        themeIcon.textContent = '☀️';
        themeText.textContent = 'Light';
      }
    }
    try {
      localStorage.setItem('stygian-theme', theme);
    } catch (_) {}
  };

  applyTheme(getSavedTheme());

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', () => {
      const current = document.documentElement.getAttribute('data-theme') || 'dark';
      const next = current === 'dark' ? 'light' : 'dark';
      applyTheme(next);
    });
  }

  // 2. Client-side Search Filter
  const searchInput = document.getElementById('docsSearchInput');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      const query = e.target.value.toLowerCase().trim();
      const searchableElements = document.querySelectorAll('h2, h3, .stygian-card, p');
      
      if (!query) {
        searchableElements.forEach(el => el.style.opacity = '1');
        return;
      }

      searchableElements.forEach(el => {
        const text = el.textContent.toLowerCase();
        if (text.includes(query)) {
          el.style.opacity = '1';
        } else {
          el.style.opacity = '0.35';
        }
      });
    });
  }

  // 3. Highlight Active Sidebar Link
  const currentPath = window.location.pathname;
  const sidebarLinks = document.querySelectorAll('.sidebar-nav-link');
  sidebarLinks.forEach(link => {
    if (link.getAttribute('href') === currentPath || currentPath.endsWith(link.getAttribute('href'))) {
      link.classList.add('active');
    }
  });
});
