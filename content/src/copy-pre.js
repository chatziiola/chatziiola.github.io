document.addEventListener("DOMContentLoaded", function () {
    // Load Highlight.js dynamically
    function loadHighlightJs(callback) {
        if (document.querySelector('script[src="/src/highlight.min.js"]')) return;
        let script = document.createElement("script");
        script.src = "/src/highlight.min.js";
        script.onload = callback || function () { hljs.highlightAll(); };
        document.head.appendChild(script);
    }

    // Toggle syntax highlighting
    function toggleHighlighting() {
        if (window.hljs) {
            document.querySelectorAll("pre").forEach((block) => {
                if (block.classList.contains("hljs")) {
                    block.classList.remove("hljs");
                    block.innerHTML = block.textContent; // Remove formatting
                } else {
                    hljs.highlightElement(block);
                }
            });
        }
    }

    // Add Dark Mode Toggle
    function addDarkModeToggle() {
        const targetElement = document.getElementById('org-div-home-and-up');
        if (!targetElement) {
            console.error('Element with id "org-div-home-and-up" not found.');
            return;
        }

        const button = document.createElement('button');
        button.className = "theme-toggle";
        button.innerHTML = `<i class="fas fa-moon"></i>`;
        button.style.cssText = "size: 1em; background: none; border: none; cursor: pointer; text-decoration: none;";
        targetElement.append('|', button);

        // Set initial theme
        if (localStorage.getItem('theme') === 'dark') {
            document.body.classList.add('dark-mode');
            button.innerHTML = `<i class="fas fa-sun"></i>`;
        }

        // Toggle dark mode
        button.addEventListener('click', () => {
            document.body.classList.toggle('dark-mode');
            const isDark = document.body.classList.contains('dark-mode');
            button.innerHTML = `<i class="fas ${isDark ? 'fa-sun' : 'fa-moon'}"></i>`;
            localStorage.setItem('theme', isDark ? 'dark' : 'light');
        });
    }

    // Add Copy Buttons to Code Blocks
    function addCopyButtons() {
        document.querySelectorAll('pre').forEach((pre) => {
            if (pre.querySelector('.copy-button')) return; // Prevent duplicate buttons

            const button = document.createElement('button');
            button.className = "copy-button";
            button.innerHTML = `<i class="fa-regular fa-clipboard"></i>`;

            pre.style.position = "relative";
            button.style.cssText = "position: absolute; top: 8px; right: 8px; background: none; border: none; cursor: pointer;";
            pre.appendChild(button);

            button.addEventListener("click", () => {
                const content = pre.querySelector("code")?.textContent.trim() || pre.textContent.trim();
                navigator.clipboard.writeText(content).then(() => {
                    button.innerHTML = `<i class="fa-solid fa-check"></i>`;
                    setTimeout(() => button.innerHTML = `<i class="fa-regular fa-clipboard"></i>`, 1000);
                }).catch(err => console.error("Error copying:", err));
            });
        });
    }

    // Magnify Images on Click
    function addImageMagnifyFeature() {
        document.body.addEventListener("click", (event) => {
            if (event.target.tagName === "IMG") {
                event.target.classList.toggle("magnify-image");
            }
        });
    }

    // Initialize Features
    loadHighlightJs();
    toggleHighlighting();
    addDarkModeToggle();
    addCopyButtons();
    addImageMagnifyFeature();
});
