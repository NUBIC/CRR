@showHideMore = (target, applyToContainer) ->
  getDisplayList = (triggerElement) ->
    if applyToContainer
      $displayList = triggerElement.closest('.show-hide-container').find('.more_display')
    else
      $displayList = triggerElement.closest('.show-hide-group').find('.more_display')
    return $displayList

  moreLabel = 'See more...'
  lessLabel = 'See less...'

  $.each $('.show_button', target), () ->
    $element      = $(this)
    $element.text(moreLabel)

    $displayList  = getDisplayList($(this))
    $displayList.hide()

    $element.on 'click', () ->
      if $element.text() == moreLabel
        $displayList.show()
        $element.text(lessLabel)
      else
        $displayList.hide()
        $element.text(moreLabel)

@setTableHeader = (element_id, target) ->
  header = $('#' + element_id + ' .table-header[data-target-table="' + $(target).attr('id') + '"]')
  $('#' + $(target).attr('id') + '_wrapper .data-table-info-header').html(header.html())
  header.hide()

$('a.maintenance_mode_link').livequery ->
  $(this).on 'ajax:success', () ->
    location.reload()

$('a[data-toggle=modal]').livequery ->
  $(this).on 'click', () ->
    console.log 'here'
    $($(this).attr('data-target')).html("<h5 class='modal-header text-center'>Loading...</h5>")
    $($(this).attr('data-target')).load($(this).attr('href'))

# Bootstrap popover with custom click outside of popover and close(x) icon on popover

$('[data-toggle=popover]').livequery ->
  $(this).popover();

$(".popover-title").livequery ->
  $(this).append('<button type="button" class="close popover-close">&times;</button>')

$(".popover-close").livequery 'click', (e) ->
  $('[data-toggle="popover"]').popover('hide')

$('body').livequery 'click', (e) ->
  if $(e.target).data('toggle') != 'popover' && $(e.target).parents('[data-toggle="popover"]').length == 0 && $(e.target).parents('.popover.in').length == 0
    $('[data-toggle="popover"]').popover('hide');




