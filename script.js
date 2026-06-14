document.addEventListener("DOMContentLoaded", () => {
    // Collect all loaded poem card elements inside the container wrapper layers
    const poems = document.querySelectorAll(".poem-card");
    const prevBtn = document.getElementById("prevBtn");
    const nextBtn = document.getElementById("nextBtn");
    let currentIndex = 0;

    // Guard handler check to prevent execution errors if nodes are missing
    if (poems.length === 0 || !prevBtn || !nextBtn) return;

    function showPoem(nextIndex) {
        // Toggle active display framework properties off from current open card
        poems[currentIndex].classList.remove("active");
        
        // Loop position securely across arrays length constraints forward or backward
        currentIndex = (nextIndex + poems.length) % poems.length;
        
        // Activate target poem element container view 
        poems[currentIndex].classList.add("active");
        
        // Automatically snap internal card content layout tracking bar back to top index
        const innerBody = poems[currentIndex].querySelector(".poem-body");
        if (innerBody) {
            innerBody.scrollTop = 0;
        }
    }

    // Connect button element click listeners directly to index increment loops
    prevBtn.addEventListener("click", () => showPoem(currentIndex - 1));
    nextBtn.addEventListener("click", () => showPoem(currentIndex + 1));
});
