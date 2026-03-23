(function() {
  const toggleBtn = document.getElementById('theme-toggle');
  const doc = document.documentElement;

  // 1. Determine theme (Priority: localStorage > System Preference)
  const getInitialTheme = () => {
    const saved = localStorage.getItem('theme');
    if (saved) return saved;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  };

  // 2. Simple Apply function
  const applyTheme = (theme, save = false) => {
    doc.setAttribute('data-theme', theme);
    toggleBtn.textContent = theme === 'dark' ? 'light mode' : 'dark mode';
    if (save) localStorage.setItem('theme', theme);
  };

  // 3. Initialize
  const currentTheme = getInitialTheme();
  applyTheme(currentTheme);

  // 4. Toggle Event
  toggleBtn.addEventListener('click', () => {
    const nextTheme = doc.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    applyTheme(nextTheme, true);
  });

  // 5. Listen for OS changes
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
    if (!localStorage.getItem('theme')) {
      applyTheme(e.matches ? 'dark' : 'light');
    }
  });
})();
