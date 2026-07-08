document.addEventListener("DOMContentLoaded", () => {
    console.log("Script loaded!");

    const poems = document.querySelectorAll(".poem-card");
    const prevBtn = document.getElementById("prevBtn");
    const nextBtn = document.getElementById("nextBtn");

    console.log(poems.length);
    console.log(prevBtn);
    console.log(nextBtn);

    let currentIndex = 0;

    function showPoem(nextIndex) {
        console.log("Current:", currentIndex);
console.log("Going to:", nextIndex);

poems[currentIndex].classList.remove("active");

currentIndex = (nextIndex + poems.length) % poems.length;

console.log("New current:", currentIndex);

poems[currentIndex].classList.add("active");
    }

    prevBtn.addEventListener("click", () => {
        alert("Previous clicked");
        showPoem(currentIndex - 1);
    });

    nextBtn.addEventListener("click", () => {
        alert("Next clicked");
        showPoem(currentIndex + 1);
    });
});