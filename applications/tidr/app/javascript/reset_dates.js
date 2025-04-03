document.addEventListener("DOMContentLoaded", function () {
  const resetButton = document.getElementById("reset_dates");
  if (!resetButton) return; // Exit if button is not present

  resetButton.addEventListener("click", function () {
    document.getElementById("from_date").value = resetButton.dataset.defaultFrom;
    document.getElementById("to_date").value = resetButton.dataset.defaultTo;
  });
});

