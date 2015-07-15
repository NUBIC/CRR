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
