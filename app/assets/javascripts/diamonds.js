$(function() {
  $("#diamonds .pagination .next_page").on("click", function() {
    $.getScript(this.href);
    return false;
  });
});

function hideLoadingBar() {
  $('#loadingBar').hide();
}

function showLoadingBar() {
  $('#loadingBar').show();
}

function updateSearch(){
  showLoadingBar();
  $.get(
    $("#diamonds_search").attr("action"),
    $("#diamonds_search").serialize(),
    null,
    "script")
    .always(hideLoadingBar);
  return false;
}
