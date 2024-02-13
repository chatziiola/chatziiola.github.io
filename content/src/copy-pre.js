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
    // Find all images on the page
    const images = document.querySelectorAll('img');
    images.forEach(function(img) {
        img.addEventListener('click', function() {
            // Toggle a class that magnifies the image
            this.classList.toggle('magnify-image');
        });
    });
});
