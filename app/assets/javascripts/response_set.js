$(document).ready(function() {
  $('form#load_from_file').livequery(function(){
    var $form = $(this);
    var $target = $($form.attr('data-target'));
    $form.ajaxForm({
      target: $target,
      dataType: 'html',
      success: function(data,message,xhr) {
        $target.html(data);
        $('.modal-backdrop').fadeOut();
        console.log(xhr.getResponseHeader('x-flash-errors'))
        if (xhr.getResponseHeader('x-flash-notice') !== null){
          $(".notifications").notify({
            message: { text: xhr.getResponseHeader('x-flash-notice') }
          }).show();
        }
        if (xhr.getResponseHeader('x-flash-errors') !== null){
          $notification = $('<div>').addClass('alert alert-error')
          .html(xhr.getResponseHeader('x-flash-errors'))
          .appendTo($('.errors'))
          .prepend($('<a>').addClass('close').attr('data-dismiss', 'alert').html('x'))
        }
      }
    })
  });

  function resizeSurvey() {
    if ($('#survey-tab-content').length){
      var tab_content_height = $(window).height() - $('#survey-tab-content').offset().top - 1.25 * $('.footer').height();
      $('#survey-tab-content').height(tab_content_height).css({ overflow: "auto"});
      $('#survey-tabs li, .previous-section, .next-section, .finish-section').click( function(){
        $('#survey-tab-content').height(tab_content_height).css({ overflow: "auto" });
        $('#survey-tab-content').scrollTop(0);
      });
    }
  }

  // From  https://github.com/NUBIC/notis-crf/blob/next/app/assets/javascripts/common/form_builder_upload.js
  var $file_upload_row = $('form.edit_response_set_form').find('div[data-response-set-upload-file-fields]');
  $.each($file_upload_row, function(){
    var $row = $(this),
        $file_upload_field  = $row.find('input[type="file"]'),
        $file_upload_link   = $row.find('a[data-response-set-upload-file-link]'),
        $file_upload_delete_link  = $row.find('a[data-response-set-upload-file-remove-link]'),
        $file_upload_delete_field = $row.find('input[data-response-set-file-upload-remove-field]');

    if($file_upload_link.length){
      $file_upload_field.hide();
    }

    $file_upload_delete_link.on('click', function() {
      if($file_upload_field.size() != 0){
        $file_upload_field.wrap('<form>').closest('form').get(0).reset();
        $file_upload_field.unwrap();
      }
      $file_upload_link.hide();
      $(this).hide();
      $file_upload_delete_field.val('1');
      $file_upload_field.show();
    })
    $file_upload_field.on("change", function(){
      $file_upload_delete_field.val('0');
    });
  })

  resizeSurvey();

  $(window).resize(function() {
    resizeSurvey();
  });
});

