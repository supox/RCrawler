$(function() {
  $("#diamonds th a, #diamonds .pagination a").on("click", function() {
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
}
