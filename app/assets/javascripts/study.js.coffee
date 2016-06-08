$(document).ready ->
  location.hash && $(location.hash + '.collapse').collapse('show');

  $('#study_list').livequery ->
    initializeDefaultTable($(this))