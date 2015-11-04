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
  })
});

