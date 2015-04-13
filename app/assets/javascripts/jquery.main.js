var timeoutWarningTimer;
var timeoutExpiredTimer;

$(document).ready(function() {

  //--------------- Change default Bootstrap date----------
  $.fn.datepicker.defaults.format = "mm/dd/yyyy";

  $.validator.setDefaults({
    errorPlacement: function(error, element) {
      if( element.attr("type") === "checkbox" || element.attr("type") === "radio") {
        element.closest('.control-group').append(error);
      } else if (element.is("select")) {
        element.closest('.select').append(error);
      } else {
        error.insertAfter(element);
      }
    }
  });
  // -------------- Common UI --------------
  $('a[data-toggle=modal]').livequery('click',function(){
    $($(this).attr('data-target')).html("<h5 class='modal-header text-center'>Loading...</h5>");
    $($(this).attr('data-target')).load($(this).attr('href'));
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
           $(".notifications").notify({
               message: { text: xhr.getResponseHeader('x-flash-errors') },
               type: "error"
                 }).show();
         }
       }
   } );});

  $(".release-data-ajax-form").livequery(
    'submit', function(e){
      var formData= $(this).serializeArray();
      var table = $('#search_result_list').dataTable();
      var allData =table.$('input').serializeArray().concat(formData);
      $.ajax({
        type:"POST",
        url: $(this).attr("action"),
        data: allData,
        success: function(data,message,xhr) {
          if (xhr.getResponseHeader('x-flash-errors') !== null){
            $(".notifications").notify({
              message: { text: xhr.getResponseHeader('x-flash-errors') },
              type: "error"
            }).show();
          }
       }
      });
      return false;
    });

  // -------------- datatables --------------
  $('#index_list').livequery(function(){
    $(this).dataTable( {
      "fnInfoCallback ": function() {showHideMore();},
      "bScrollCollapse": true,
      "sPaginationType": "bootstrap",
      "sDom": "<'row-fluid'<'span6 header'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "sWrapper": "dataTables_wrapper form-inline",
      "aaSorting": [],
      "bFilter": true,
      "iDisplayLength": 30,
      "bLengthChange": false,
      "oLanguage": {
          "sSearch": "Filter: ",
      }
    });
  });

  $('#survey_list').livequery(function(){
    $(this).dataTable( {
      "fnInfoCallback ": function() {showHideMore();},
      "bScrollCollapse": true,
      "sPaginationType": "bootstrap",
      "sDom": "<'row-fluid'<'span6 survey-header'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "sWrapper": "dataTables_wrapper form-inline",
      "aaSorting": [],
      "bFilter": true,
      "iDisplayLength": 30,
      "bLengthChange": false,
      "oLanguage": {
          "sSearch": "Filter: ",
      }
    });
  });

  $('#user_list').livequery(function(){
    showHideMore();
    $(this).dataTable( {
      "fnInfoCallback ": function() {showHideMore();},
      "bScrollCollapse": true,
      "sPaginationType": "bootstrap",
      "sDom": "<'row-fluid'<'span6 header'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "sWrapper": "dataTables_wrapper form-inline",
      "aaSorting": [],
      "bFilter": true,
      "iDisplayLength": 30,
      "bLengthChange": false,
      "oLanguage": {
          "sSearch": "Filter: ",
      }
    });
  });

  $('#study_participant_list').livequery(function(){
    $(this).dataTable( {
      "fnInfoCallback ": function() {showHideMore();},
      "bScrollCollapse": true,
      "sPaginationType": "bootstrap",
      "sDom": "<'row-fluid'<'span6 study-participant-header'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "sWrapper": "dataTables_wrapper form-inline",
      "aaSorting": [],
      "bFilter": true,
      "iDisplayLength": 30,
      "bLengthChange": false,
      "oLanguage": {
          "sSearch": "Filter: ",
      }
    });
  });

  $('#dashboard_list').livequery(function(){
    showHideMore();
    $(this).dataTable( {
      "fnInfoCallback ": function() {showHideMore();},
      "bScrollCollapse": true,
      "sPaginationType": "bootstrap",
      "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "sWrapper": "dataTables_wrapper form-inline",
      "aaSorting": [],
      "bFilter": true,
      "iDisplayLength": 30,
      "bLengthChange": false,
      "oLanguage": {
          "sSearch": "Filter: ",
      }
    });
  });

  $('#participants_list').livequery(function(){
    showHideMore();
    $(this).dataTable( {
      "fnInfoCallback ": function() {showHideMore();},
      "bScrollCollapse": true,
      "sPaginationType": "bootstrap",
      "sDom": "<'row-fluid'<'span6 header'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
      "sWrapper": "dataTables_wrapper form-inline",
      "aaSorting": [],
      "bFilter": true,
      "iDisplayLength": 30,
      "bLengthChange": false,
      "oLanguage": {
          "sSearch": "Filter: ",
      }
    });
  });

  $('#study_history_list').livequery(function(){
    $(this).dataTable( {
      "bScrollCollapse": true,
      "sPaginationType": "bootstrap",
      "sDom": "t<'row'<'span6'i><'span6'>>",
      "sWrapper": "dataTables_wrapper form-inline",
      "aaSorting": [],
      "iDisplayLength": 30,
      "bLengthChange": false,
    });
  });

  $('#contact_log_list').livequery(function(){
    $(this).dataTable( {
      "bScrollCollapse": true,
      "sPaginationType": "bootstrap",
      "sDom": "t<'row'<'span6'i><'span6'>>",
      "sWrapper": "dataTables_wrapper form-inline",
      "aaSorting": [],
      "iDisplayLength": 30,
      "bLengthChange": false,
    });
  });

  $('#participant_survey_list').livequery(function(){
    $(this).dataTable( {
      "bScrollCollapse": true,
      "sPaginationType": "bootstrap",
      "sDom": "t<'row'<'span6'i><'span6'>>",
      "sWrapper": "dataTables_wrapper form-inline",
      "aaSorting": [],
      "iDisplayLength": 30,
      "bLengthChange": false,
    });
  });

  function showHideMore() {
    $('table tr ul li.more_display').hide();
    $('.show_button').livequery('click',function(e) {
      $end_date_list = $(this).closest('td').next().children('ul').find('li.more_display');
      $display_name_list = $(this).siblings('ul li.more_display');
      $(this).text(function (_, value) {
        if (value == 'See more...') {
          $end_date_list.show();
          $display_name_list.show();
          return "See less..."
        } else {
          $end_date_list.hide();
          $display_name_list.hide();
          return "See more..."
        }
      });
    });
  }

  $(".next-section").livequery('click',function(e){
    if ($('.edit_response_set_form').valid()) {
      remove_error_message();
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
      display_error_message();
    }
    return false
  });

  $(".finish-section").livequery('click',function(e){
    if ($('.edit_response_set_form').valid()) {
      remove_error_message();
    } else {
      display_error_message();
    }
  });

  $(".previous-section").livequery('click',function(){
    remove_error_message();
    var $tabs = $('.tabs-left li');
    $tabs.filter('.active').prev('li').find('a[data-toggle="tab"]').tab('show');
  });

  function remove_error_message() {
    $('#custom_error').remove();
    $('div.error').removeAttr('style');
    $('.error').removeClass('error');
  }

  function display_error_message() {
    $('.error').closest('.control-group').addClass("error").css({"background-color": "#f2dede"});
    if ($('#custom_error').length < 1) {
      $(".error-msg").append($("<div id='custom_error' class='alert alert-error'></div>").
        text("You missed something! See below"));
    }
  }

  $(".participant_demographic").livequery(function(){
    $(this).validate({
      onfocusout: false,
      messages: {
        "participant[first_name]": "Please enter participant's First Name.",
        "participant[last_name]": "Please enter participant's Last Name.",
        "participant[primary_guardian_first_name]": "Please enter primary guardian's First Name.",
        "participant[primary_guardian_last_name]": "Please enter primary guardian's Last Name."
      }
    });
  });

  $("#new-consent-sign").livequery(function(){
    $(this).validate({
      messages: {
        "consent_signature[proxy_name]": "Please enter your full name.",
        "consent_signature[proxy_relationship]": "Please enter your relatiohsip to participant."
      }
    });
  });

  $(".consent-agree").livequery('click',function(e){
    $(".proxy-consent").show();
    $("#consent_response").val("accept");
    $("#consent-next").removeAttr("disabled");
  });

  $(".consent-disagree").livequery('click',function(e){
    $(".proxy-consent").hide();
    $("#consent_response").val("decline");
    $("#consent-next").removeAttr("disabled");
  });

  $(".destination_relationship").livequery(function(){
    var name_text = $(this).find('option:selected').text();
    $(this).parent().append($("<span class='destination_relationship_name'></span>").text(name_text));
  });

  $(".label-required").livequery(function(){
    $(this).append($("<small class='text-error'><i>Required field</i></small>"));
  });

  $(".header").livequery(function(){
    if ($('#additonal-data').length) {
      $(this).append($("<h4>" + $('#additonal-data').data("header") + "<a class='btn btn-primary nu-primary' style='margin-left: 15px' href=" + $('#additonal-data').data("url")+ ">"+ $('#additonal-data').data("text") + "</a>" + "</h4>"));
    }
  });

  $(".survey-header").livequery(function(){
    $(this).append($("<h4>" + $('#additonal-data').data("header") + "<a class='btn btn-primary nu-primary' style='margin-left: 15px' data-target='"+$('#additonal-data').data("target")+"' data-async='true' href=" + $('#additonal-data').data("url")+ ">Add a survey</a>" + "</h4>"));
  });

  $(".study-participant-header").livequery(function(){
    if ($('#additonal-data').data("count") > 0)
      $(this).append($("<div class='user-circle input-append'></div>")).append($("<span style='margin-left: 15px'>" + $('#additonal-data').data("header") + "</span>"));
    else
      $(this).append($("<div class='input-append'></div>")).append($("<span>" + $('#additonal-data').data("header") + "</span>"));
  });

  $('.consent-agree').attr('disabled', 'disabled');
  $('.consent-agree-text').addClass('muted')

  $("#consent-next").attr("disabled", "disabled");
  $(".proxy-consent").hide();

  $('#consent-content').scroll(function(){
    var $contentelement =  $(this)[0];
    if (($contentelement.scrollTop + $contentelement.offsetHeight) >= $contentelement.scrollHeight){
      $('.consent-agree').removeAttr('disabled');
      $('.consent-agree-text').addClass('text-success');
    }
  });

  $(".edit_response_set_form").livequery(function(){
    $(this).validate();
  });

  $(".validate-form").livequery(function(){
    $(".phone").mask("999-999-9999");
    $(".date").mask("99/99/9999");
    $(".zipcode").mask("99999");
    $(this).validate({onfocusout: false});
  });

  $('#search-end-of-release-date').livequery(function(){
    $(this).change(function() {
      var releaseDate = $("#search-release-date").val();
      var endOfReleaseDate = new Date();
      endOfReleaseDate.setDate(new Date(releaseDate).getDate() + 14);
      if($(this).val() == '' || $(this).val() == releaseDate ) {
        $(this).datepicker('setDate', endOfReleaseDate).datepicker('update');
      }
    });
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
    return this.optional(element) || isDate(date);
  }, "Please specify a valid date in 'MM/DD/YYYY' format.");

  $.validator.addMethod("birth-date", function(date, element) {
    return this.optional(element) || isBirthDate(date);
  }, "Birthdate can't be in future or more than 125 years ago.");

  $.validator.addMethod("number", function(value, element) {
    return this.optional(element) || value.match(/^\d+$/);
  }, "Please specify a valid number");

  $(".phone").mask("999-999-9999");
  $(".date").mask("99/99/9999");
  $(".zipcode").mask("99999");

  function isDate(txtDate)
  {
    var currVal = txtDate;
    var rxDatePattern = /^(\d{1,2})(\/)(\d{1,2})(\/)(\d{4})$/;
    var dtArray = currVal.match(rxDatePattern);

    if (dtArray == null)
       return false;

    var dtMonth = dtArray[1];
    var dtDay= dtArray[3];
    var dtYear = dtArray[5];

    if (dtMonth < 1 || dtMonth > 12)
      return false;
    else if (dtDay < 1 || dtDay> 31)
      return false;
    else if ((dtMonth== 4 || dtMonth== 6 || dtMonth== 9 || dtMonth== 11) && dtDay == 31)
      return false;
    else if (dtMonth == 2)
    {
       var isleap = (dtYear % 4 == 0 && (dtYear % 100 != 0 || dtYear % 400 == 0));
       if (dtDay > 29 || (dtDay == 29 && !isleap))
        return false;
    }
    return true;
  }

  function isBirthDate(txtDate){
    var currVal = txtDate;
    var rxDatePattern = /^(\d{1,2})(\/)(\d{1,2})(\/)(\d{4})$/;
    var dtArray = currVal.match(rxDatePattern);

    if (dtArray == null)
       return false;

    var dtMonth = dtArray[1] - 1;
    var dtDay= dtArray[3];
    var dtYear = dtArray[5];
    var inputDate = new Date();
    inputDate.setFullYear(dtYear, dtMonth, dtDay);
    var now = new Date();
    var pastDate = new Date();
    pastDate.setFullYear(pastDate.getFullYear() - 125);
    if((inputDate > now) || (inputDate < pastDate)) {
      return false;
    }
    return true;
  }
});
jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");} });
