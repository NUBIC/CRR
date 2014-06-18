var timeoutWarningTimer;
var timeoutExpiredTimer;

$(document).ready(function() {

  //--------------- Change default Bootstrap date----------
  $.fn.datepicker.defaults.format = "yyyy-mm-dd";
  // -------------- Common UI --------------
  $('a[data-toggle=modal]').livequery('click',function(){
    $($(this).attr('data-target')).html("<h5 class='modal-header text-center'>Loading...</h5>");
    $($(this).attr('data-target')).load($(this).attr('href'));
  });

  $('#selectall').on('click', function() {
    $('.selectalloption').prop('checked', $(this).is(":checked"));
  });

  $(".wyswig").livequery(function(){
    $(this).jqte();
    });

  $("a[data-async=true]").livequery('click',function(){
    $($(this).attr("data-target")).load( $(this).attr("href"));
    return false;
  });

  $(".tokeninput").livequery(
    function(){
    $(this).tokenInput($(this).data("url"),{crossDomain: false,propertyToSearch: 'search_display',minChars: 3,tokenLimit: $(this).data("limit"), theme: $(this).data("theme"),hintText: $(this).data("hint-text")});
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
         if (xhr.getResponseHeader('x-flash-notice') !== null){
             $(".notifications").notify({
                 message: { text: xhr.getResponseHeader('x-flash-notice') }
                   }).show();
         }
         if (xhr.getResponseHeader('x-flash-errors') !== null){
           $(".errors").notify({
               message: { text: xhr.getResponseHeader('x-flash-errors') },
               type: "error"
                 }).show();
         }
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

  $(".next-section, .finish-section").livequery('click',function(e){
    if ($('#edit_response_set_form').valid()) {
      $('#custom_error').remove();
      $('div.error').removeAttr('style');
      $('.error').removeClass('error');
      var $tabs = $('.tabs-left li');
      $tabs.filter('.active').next('li').find('a[data-toggle="tab"]').tab('show');
      var $form = $("form.validate-form");
      var $target = $($form.attr('data-target'));
      $.ajax({
        type: "PUT",
        target: $target,
        data: $form.serialize(),
        url: $(this).attr('data-url'),
        success: function(data,message,xhr) {
          $target.html(data);
          if (xhr.getResponseHeader('x-flash-notice') !== null){
            $(".notifications").notify({
              message: { text: xhr.getResponseHeader('x-flash-notice') }
            }).show();
          }
        },
        error: function(xhr,status,error) {
          if (xhr.getResponseHeader('x-flash-errors') !== null){
            $(".errors").notify({
              message: { text: xhr.getResponseHeader('x-flash-errors') },
              type: "error"
            }).show();
          }
        }
      });
    } else {
      $('.error').closest('.control-group').addClass("error").css({"background-color": "#f2dede"});
      if ($('#custom_error').length < 1) {
        $(this).parent().parent().siblings(".section-title").
          append($("<div id='custom_error' class='alert alert-error'></div>").
          text("You have miss something! See below"));
      }
    }
    return false
  });

  $(".phone").mask("999-999-9999");
  $(".date").mask("9999-99-99");
  $(".zipcode").mask("99999");

  $(".previous-section").livequery('click',function(){
    var $tabs = $('.tabs-left li');
    $tabs.filter('.active').prev('li').find('a[data-toggle="tab"]').tab('show');
  });

  $.validator.setDefaults({
    errorPlacement: function(error, element) {
      if( element.attr("type") === "checkbox") {
        element.closest('.control-group').append(error);
      } else {
        error.insertAfter(element);
      }
    }
  });

  $.validator.addMethod("phone", function(value, element) {
    phone_number = value.replace(/\s+/g, "");
    return this.optional(element) || phone_number.length > 9 && phone_number.match(/^\d{3}-\d{3}-\d{4}$/);
    // phone_number.match(/^(\+?1-?)?(\([2-9]\d{2}\)|[2-9]\d{2})-?[2-9]\d{2}-?\d{4}$/);
  }, "Please enter a valid phone number in 'xxx-xxx-xxxx' format.");

  $.validator.addMethod("zipcode", function(value, element) {
    return this.optional(element) || /\d{5}-\d{4}$|^\d{5}$/.test(value);
  }, "Please enter a valid US Zip Code.");

  $.validator.addMethod("date", function(date, element) {
    return this.optional(element) || date.match(/^(19|20)\d\d-(0\d|1[012])-(0\d|1\d|2\d|3[01])$/);
  }, "Please specify a valid date in 'yyyy-mm-dd' format.");
});
jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");} });
