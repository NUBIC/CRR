$(document).ready(function() {
  var $container  = $('#express_sign_up'),
      $phoneInputContainer    = $container.find('input#phone').closest('.control-group'),
      $emailInputContainer    = $container.find('input#email').closest('.control-group'),
      $contactInput           = $container.find('select#contact');

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
});