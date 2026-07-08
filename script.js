document.addEventListener("DOMContentLoaded", () => {
    const poems = document.querySelectorAll(".poem-card");
    const prevBtn = document.getElementById("prevBtn");
    const nextBtn = document.getElementById("nextBtn");
    let currentIndex = 0;

    if (poems.length === 0 || !prevBtn || !nextBtn) return;

    function showPoem(nextIndex) {
        poems[currentIndex].classList.remove("active");
        currentIndex = (nextIndex + poems.length) % poems.length;
        poems[currentIndex].classList.add("active");
        
        const innerBody = poems[currentIndex].querySelector(".poem-body");
        if (innerBody) {
            innerBody.scrollTop = 0;
        }
    }
prevBtn.addEventListener("click", () => {
    console.log("Previous clicked");
    showPoem(currentIndex - 1);
});

nextBtn.addEventListener("click", () => {
    console.log("Next clicked");
    showPoem(currentIndex + 1);
});