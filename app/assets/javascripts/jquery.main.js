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
    $(this).tokenInput($(this).data("url"),{crossDomain: false,propertyToSearch: 'search_display',minChars: 3,tokenLimit: 1, theme: $(this).data("data-theme"),hintText: $(this).data("data-hint-text")});
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
  $(".participant_demographic").validate();
  $(".relationship").hide();
  $('input[id=participant_last_name]').blur(function() {
    $(".relationship").show();
    $(".participant_full_name").text($("#participant_first_name").val() + " " + $(this).val());
  });
  $("#new_consent_sign").validate();
  $("#consent_next_button").attr("disabled", "disabled");
  $(".proxy_consent_name").hide();
  $(".consent_agree").click(function(ele){
    $(".proxy_consent_name").show();
    $("#consent_response").val("accept");
    $("#consent_next_button").removeAttr("disabled");
  });
  $(".consent_disagree").click(function(){
    $(".proxy_consent_name").hide();
    $("#consent_response").val("decline");
    $("#consent_next_button").removeAttr("disabled");
  });
});
jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");} });
