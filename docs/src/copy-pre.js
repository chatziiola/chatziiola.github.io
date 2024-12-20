// Src: https://codepen.io/Umer_Farooq/pen/eYJgKGN
function addDarkModeToggle() {
    // Create a button that looks like a link
    const container = document.createElement('button');
    container.setAttribute("class", "theme-toggle");
    container.style.background = "none";
    container.style.border = "none";
    container.style.cursor = "pointer";
    container.style.textDecoration = "none";

    // Create an <i> element for the moon icon
    const icon = document.createElement('i');
    icon.setAttribute("class", "fas fa-moon");
    icon.style.fontSize = "1em";
    container.appendChild(icon);

    // Append the container to the element with id org-div-home-and-up
    const targetElement = document.getElementById('org-div-home-and-up');
    if (targetElement) {
        targetElement.append('|');
        targetElement.append(container);
    } else {
        console.error('Element with id "org-div-home-and-up" not found.');
        return;
    }

    // Check localStorage for the theme and apply it
    const currentTheme = localStorage.getItem('theme');
    if (currentTheme === 'dark') {
        document.body.classList.add('dark-mode');
        icon.setAttribute("class", "fas fa-sun");
    }

    // Add an event listener to toggle the dark-mode class
    container.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        if (document.body.classList.contains("dark-mode")) {
            icon.setAttribute("class", "fas fa-sun");
            localStorage.setItem('theme', 'dark');
        } else {
            icon.setAttribute("class", "fas fa-moon");
            localStorage.setItem('theme', 'light');
        }
    });
}

document.addEventListener("DOMContentLoaded", function() {
    // Function to add copy button to pre elements
    function addCopyButtonToPreElements() {
        // Get all pre elements
        var preElements = document.querySelectorAll('pre');
        
        // Iterate over each pre element
        preElements.forEach(function(preElement) {
            // Create a button
            var copyButton = document.createElement('button');
            copyButton.textContent = 'Copy';
            copyButton.classList.add('copy-button');
            
            // Append the button to the pre element
            preElement.appendChild(copyButton);
            
            // Add click event listener to the button
            copyButton.addEventListener('click', function() {
		// Get the text content of the pre element
                var contentToCopy = preElement.textContent.trim();
                
                // Remove the button's text content from the end
                contentToCopy = contentToCopy.slice(0, -copyButton.textContent.length);
                
                navigator.clipboard.writeText(contentToCopy).then(function() {
                    console.log('Content copied to clipboard:', contentToCopy);
                }, function(err) {
                    console.error('Error copying content to clipboard:', err);
                });
            });
        });
    }
    
    // Call the function to add copy buttons to pre elements
    addCopyButtonToPreElements();
});

// JavaScript to magnify images on click
document.addEventListener('DOMContentLoaded', function() {
    addDarkModeToggle();

    // Find all images on the page
    const images = document.querySelectorAll('img');
    images.forEach(function(img) {
        img.addEventListener('click', function() {
            // Toggle a class that magnifies the image
            this.classList.toggle('magnify-image');
        });
    });
});




