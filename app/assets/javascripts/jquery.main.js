var timeoutWarningTimer;
var timeoutExpiredTimer;

$(document).ready(function() {
  // -------------- Common UI --------------


  $('a[data-toggle=modal]').livequery('click',function(){
    $($(this).attr('data-target')).html("<h5 class='modal-header text-center'>Loading...</h5>");
    $($(this).attr('data-target')).load($(this).attr('href'));
  });

  $("a[data-async=true]").livequery('click',function(){
    $($(this).attr("data-target")).load( $(this).attr("href"));
    return false;
  });

  // -------------- datatables --------------
  // index (my studies) datatable
  $('#participant_list').livequery(function(){$(this).dataTable( { 
  "bScrollCollapse": true,
  "sPaginationType": "bootstrap",
  "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
  "sWrapper": "dataTables_wrapper form-inline",
  "bFilter": true, 
  "iDisplayLength": 30,
  "bLengthChange": false,
  "oLanguage": {
      "sSearch": "Filter: "
        }});});

});
jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");} });
