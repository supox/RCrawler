$(function() {
  $("#diamonds .pagination .next_page").on("click", function() {
    $.getScript(this.href);
    return false;
  });
});


function updateSearch(){
  $.get(
    $("#diamonds_search").attr("action"),
    $("#diamonds_search").serialize(),
    null,
    "script");
  return false;
}
