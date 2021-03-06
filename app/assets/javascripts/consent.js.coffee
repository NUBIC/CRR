$(document).ready ->
  $("#new-consent-sign").livequery ->
    $(this).validate({
      messages: {
        "consent_signature[proxy_name]": "Please enter your full name.",
        "consent_signature[proxy_relationship]": "Please enter your relatiohsip to participant."
      }
    });

  $(".consent-agree").livequery 'click', (e) ->
    $(".proxy-consent").show();
    $("#consent_response").val("accept");
    $("#consent-next").removeAttr("disabled");

  $(".consent-disagree").livequery 'click', (e) ->
    $(".proxy-consent").hide();
    $("#consent_response").val("decline");
    $("#consent-next").removeAttr("disabled");


  $('.consent-agree').attr('disabled', 'disabled');
  $('.consent-agree-text').addClass('muted')

  $("#consent-next").attr("disabled", "disabled");
  $(".proxy-consent").hide();

  $('#consent-content').livequery ->
    $consentContainer = $(this);

    resizeConsent = () ->
      consent_content_height = $(window).height() - $consentContainer.offset().top - $('#consent-controls').height()-1.5*$('.footer').height();
      $consentContainer.height(consent_content_height).css({
        overflow: 'auto',
        border: '2px solid'
      });

    resizeConsent();

    $(window).resize ->
      resizeConsent();

    $(this).scroll ->
      $contentelement = $(this)[0]
      if ($contentelement.scrollTop + $contentelement.offsetHeight) >= $contentelement.scrollHeight
        $('.consent-agree').removeAttr('disabled');
        $('.consent-agree-text').addClass('text-success');

  $('#admin_new_consent_sign').validate();

  $('#consent_list').livequery ->
    initializeDefaultTable($(this))

