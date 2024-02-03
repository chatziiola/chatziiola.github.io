function fetchLinkPreview(link) {
    const previewContainer = document.getElementById('link-preview');

    // Extract the URL from the link
    const url = link.href;

    // Fetch link preview data using Open Graph Protocol
    fetch(`https://graph.facebook.com/v12.0/?id=${encodeURIComponent(url)}&fields=og:title,og:description,og:image`)
        .then(response => response.json())
        .then(data => {
            // Update link preview content
            previewContainer.innerHTML = `
                <strong>${data.og.title}</strong>
                <p>${data.og.description}</p>
                <img src="${data.og.image}" alt="Link Preview Image">
            `;
        })
        .catch(error => {
            console.error('Error fetching link preview:', error);
            previewContainer.innerHTML = 'Failed to fetch link preview.';
        })
        .finally(() => {
            // Display the link preview
            previewContainer.style.display = 'block';
        });

    // Position the link preview below the link
    const linkRect = link.getBoundingClientRect();
    previewContainer.style.top = `${linkRect.bottom}px`;
    previewContainer.style.left = `${linkRect.left}px`;
}
