document.addEventListener("DOMContentLoaded", function () {
  function addCopyButtons() {
    document.querySelectorAll("pre").forEach((pre) => {
      if (pre.querySelector(".copy-button")) return; // Prevent duplicate buttons

      const button = document.createElement("button");
      button.className = "copy-button";
      button.innerHTML = `<i class="fa-regular fa-clipboard"></i>`;

      pre.style.position = "relative";
      button.style.cssText =
        "position: absolute; top: 8px; right: 8px; background: none; border: none; cursor: pointer;";
      pre.appendChild(button);

      button.addEventListener("click", () => {
        const content =
          pre.querySelector("code")?.textContent.trim() ||
          pre.textContent.trim();
        navigator.clipboard
          .writeText(content)
          .then(() => {
            button.innerHTML = `<i class="fa-solid fa-check"></i>`;
            setTimeout(
              () =>
                (button.innerHTML = `<i class="fa-regular fa-clipboard"></i>`),
              1000,
            );
          })
          .catch((err) => console.error("Error copying:", err));
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

  addCopyButtons();
  addImageMagnifyFeature();
});
