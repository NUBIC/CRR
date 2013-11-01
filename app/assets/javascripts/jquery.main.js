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

  $(".tokeninput").livequery(
    function(){
    $(this).tokenInput($(this).data("url"),{crossDomain: false,propertyToSearch: 'search_display',minChars: 3,tokenLimit: 1, hintText: $(this).data("data-hint-text")});
    }
  );

   $("form.ajax-form").livequery(function(){
     var $form = $(this);
     var $target = $($form.attr('data-target'));
     $form.ajaxForm(
     {
       target: $target,//$(this).attr('data-target'),
       dataType: 'html',
       success: function(data,message,xhr) {
         $target.html(data);
         $(".notifications").notify({
             message: { text: xhr.getResponseHeader('x-flash') }
               }).show(); 
       }
   } );});

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

  // TODO: Move to the seperate js and simply
  $(".proxy_consent_name").hide();
  $(".proxy_agree").click(function(){
    $(".proxy_consent_name").show();
    $("#consent_response").val("accept");
  });
  $(".proxy_disagree").click(function(){
    $(".proxy_consent_name").hide();
    $("#consent_response").val("decline");
  });
});
jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");} });
