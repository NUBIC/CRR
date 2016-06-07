@showHideMore = (target, applyToContainer) ->
  getDisplayList = (triggerElement) ->
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

@setTableHeader = (target) ->
  $header = $('.table-header[data-target-table="' + $(target).attr('id') + '"]')
  if $header.length
    $('#' + $(target).attr('id') + '_wrapper .data-table-info-header').html($header.html())
    $header.remove()

@initializeDefaultTable = ($target, callback, sorting, header) ->
  sorting = [[ 0, "asc" ]] unless sorting
  header = 'header' unless header
  $target.dataTable( {
    fnInfoCallback: () ->
      callback
    bScrollCollapse: true,
    sPaginationType: "bootstrap",
    sDom: "<'row-fluid'<'span6 " + header + "'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
    sWrapper: "dataTables_wrapper form-inline",
    aaSorting: sorting
    bFilter: true,
    iDisplayLength: 30,
    bLengthChange: false,
    oLanguage: {
      sSearch: "Filter: ",
    }
  });

$('a.maintenance_mode_link').livequery ->
  $(this).on 'ajax:success', () ->
    location.reload()

$('a[data-toggle=modal]').livequery ->
  $(this).on 'click', () ->
    if $(this).attr('href')
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


processAcyncRequest = ($link) ->
  method  = $link.attr('data-method')
  $target = $($link.attr('data-target'))

  if method
    $.ajax({
      type: method
      url: $link.attr('href')
      dataType: 'html'
      success: (data,textStatus,jqXHR) ->
        if jqXHR.getResponseHeader('x-flash-errors') != null
          $('.errors').notify({
            message: { text: jqXHR.getResponseHeader('x-flash-errors') }
            type: "error"
          }).show()
        else
          $target.html(data)
          if jqXHR.getResponseHeader('x-flash-notice') != null
            $('.notifications').notify({
              message: { text: jqXHR.getResponseHeader('x-flash-notice') }
            }).show()
        $($link.attr('data-target')).html(data)
        $('#flash').html(jqXHR.getResponseHeader('x-flash') + '<div class=close></div>')
      error: (jqXHR, status, error) ->
        $('.errors').notify({
          message: { text: jqXHR.getResponseHeader('x-flash-errors') }
          type: "error"
        }).show()
    });
  else
    $($target).load( $link.attr('href'))
  false

$('a[data-async=true]').livequery 'click', () ->
  $link = $(this)

  if $link.attr('data-confirm')
    message = $link.attr('data-confirm')
    html    = "<div class=\"modal\" id=\"acyncConfirmationDialog\">\n  <div class=\"modal-header\">\n    <a class=\"close\" data-dismiss=\"modal\">×</a>\n    <h5>Are you sure?</h5>\n  </div>\n  <div class=\"modal-body\">\n    <p>" + message + "</p>\n  </div>\n  <div class=\"modal-footer\">\n    <a data-dismiss=\"modal\" class=\"btn btn-warning\">Cancel</a>\n    <a data-dismiss=\"modal\" class=\"btn btn-primary confirm\">OK</a>\n  </div>\n</div>"
    $(html).modal()
    $('#acyncConfirmationDialog .confirm').on 'click', () ->
      processAcyncRequest($link)
      $(html).modal('hide')
  else
    processAcyncRequest($link)
  false


