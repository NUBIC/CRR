$(document).ready(function() {
  var $container  = $('#express_sign_up'),
      $phoneInputContainer    = $container.find('input#phone').closest('.control-group'),
      $emailInputContainer    = $container.find('input#email').closest('.control-group'),
      $contactInput           = $container.find('select#contact'),
      count                   = $('#additonal-data').data('count'),
      participant             = $('#additonal-data').data('participant');

  $phoneInputContainer.hide();
  $emailInputContainer.hide();

  var adjustExpressFormInputs = function(){
    var selectedOptoin = $contactInput.find('option:selected');
    if (selectedOptoin.val() == 'email') {
      $phoneInputContainer.hide();
      $emailInputContainer.show();
    } else if (selectedOptoin.val() == 'phone') {
      $phoneInputContainer.show();
      $emailInputContainer.hide();
    } else {
      $phoneInputContainer.hide();
      $emailInputContainer.hide();
    }
  }

  $contactInput.on('change', function(){
    adjustExpressFormInputs()
  });
  adjustExpressFormInputs();

  if (count == 0) {
    $('#add_participant').modal({
      'backdrop': 'static',
      'keyboard': false,
      'show': true
    });
  }

  if (participant) {
    $('#add_another_participant').modal({
      'show': true
    });
  }
});