/*
Function to add hiddenNav class on scroll.
On scroll down the navbar hides.
On scroll up the navbar appears and is sticky.
*/

var box = document,
  nav = document.querySelector("nav"),
  posEnd = 200;

box.addEventListener("scroll", function (event) {
  var posStart = document.documentElement.scrollTop;
  if (posStart > posEnd) nav.classList.add("hiddenNav");
  else nav.classList.remove("hiddenNav");

  posEnd = posStart;
});