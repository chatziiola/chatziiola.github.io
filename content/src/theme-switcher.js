
// theme-switcher.js
(function() {
    const themeToggleButton = document.getElementById('theme-toggle');
    // Check for saved theme preference, or default to user's OS preference
    const preferDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    const savedTheme = localStorage.getItem('theme');

    function applyTheme(theme) {
        if (theme === 'dark') {
            document.documentElement.classList.add('dark-mode');
        } else {
            document.documentElement.classList.remove('dark-mode');
        }
    }

    // Set the initial theme on page load
    if (savedTheme) {
        applyTheme(savedTheme);
    } else if (preferDark) {
        applyTheme('dark');
    } else {
        applyTheme('light');
    }

    // Add click event listener to the button
    if (themeToggleButton) {
        themeToggleButton.addEventListener('click', () => {
            const currentTheme = document.documentElement.classList.contains('dark-mode') ? 'dark' : 'light';
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            applyTheme(newTheme);
            localStorage.setItem('theme', newTheme);
        });
    }
})();
