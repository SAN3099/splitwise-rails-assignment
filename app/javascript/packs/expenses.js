document.addEventListener("DOMContentLoaded", () => {
  const addButton = document.getElementById("add-item-button");
  const itemsContainer = document.getElementById("expense-items");
  const template = document.getElementById("expense-item-template")?.innerHTML;

  /* ---------------- ADD NEW ITEM ---------------- */
  if (addButton && itemsContainer && template) {
    addButton.addEventListener("click", () => {
      const id = Date.now();
      const html = template.replace(/NEW_RECORD/g, id);
      itemsContainer.insertAdjacentHTML("beforeend", html);
    });
  }

  /* ---------------- REMOVE ITEM ---------------- */
  document.addEventListener("click", (e) => {
    if (e.target.classList.contains("remove-item")) {
      e.target.closest(".expense-item-fields").remove();
    }
  });

  /* --------------- SPLIT TYPE CHANGE ------------ */
  document.addEventListener("change", (e) => {
    if (!e.target.classList.contains("split-type-select")) return;

    const itemId = e.target.dataset.itemId;
    const box = document.getElementById(`unequal-inputs-${itemId}`);
    if (!box) return;

    if (e.target.value === "unequal") {
      box.style.display = "block";
    } else {
      box.style.display = "none";
      // clear all inputs inside
      box.querySelectorAll("input").forEach(input => (input.value = ""));
    }
  });
});
