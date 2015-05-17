$(document).ready ->
  setTableHeader = (target) ->
    header = $('#search .table-header[data-target-table="' + $(target).attr('id') + '"]')
    $('#' + $(target).attr('id') + '_wrapper .data-table-info-header').html(header.html())
    header.hide()

  # ---------------- index page ----------------
  $('#search table#search_index_table').livequery ->
    table_element = $(this)
    table_element.dataTable
      bScrollCollapse: true
      sPaginationType: "bootstrap"
      sDom: "<'row-fluid'<'span6 data-table-info-header'><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
      sWrapper: "dataTables_wrapper form-inline"
      aaSorting: []
      bFilter: true
      iDisplayLength: 30
      bLengthChange: false
      oLanguage: { sSearch: "Filter:&nbsp;" }
      fnInitComplete: (oSettings, json)  ->
        setTableHeader(table_element)


  # ---------------- show/edit page ----------------
  # display results
  $('#search table#search_result_list').livequery ->
    $tableElement = $(this)

    table = $tableElement.dataTable
      bScrollCollapse: true
      sPaginationType: "bootstrap"
      sDom: "<'row-fluid'<'span6 data-table-info-header'><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
      sWrapper: "dataTables_wrapper form-inline"
      aaSorting: []
      aoColumnDefs: [{ 'bSortable': false, 'aTargets': [ 0 ] }]
      bFilter: true
      iDisplayLength: 30
      bLengthChange: false
      oLanguage: { sSearch: "Filter:&nbsp;" }
      fnInitComplete: (oSettings, json)  ->
        setTableHeader($tableElement)

    showHideMore(table.fnGetNodes(), true)

    $checkboxes      = $('.selectalloption', table.fnGetNodes())
    $releaseButton  = $('#release')
    releaseButtonText = $releaseButton.html()

    setReleaseButton = () ->
      $releaseButton.attr('disabled', !$checkboxes.is(':checked'))
      count = $checkboxes.filter(":checked").length
      label = ' participant'
      if count != 1
        label = label + 's'
      $releaseButton.html(releaseButtonText + ' ' + $checkboxes.filter(":checked").length + ' ' + label)

    setReleaseButton()

    $('#selectall').on 'click', () ->
      $checkboxes.prop('checked', $(this).is(':checked'))
      setReleaseButton()

    $checkboxes.on 'click', () ->
      $('#selectall').prop('checked', $checkboxes.filter(':checked').length == $checkboxes.length)
      setReleaseButton()

  # edit page -- search UI
  if $('.search-container .search-condition-group-container .search-condition').length == 0 && $('.search-container .search-condition-groups .search-condition-group-controls').length == 0
    $('.search-instructions').show()
    $('.search-conditions').hide()
    $('.search-condition-groups').hide()

  $('.btn-search-condition-add').livequery ->
    $(this).on 'click', () ->
      $('.search-instructions').hide()
      $('.search-conditions').show()

  $('.btn-search-condition-group-add').livequery ->
    $(this).on 'click', () ->
      $('.search-instructions').hide()
      $('.search-condition-groups').show()

  # use ajax to deliver edit/new forms, force reload page on success
  $("form.ajax-edit-form").livequery ->
    $form   = $(this)
    $target = $($form.attr('data-target'))

    validateSearchCondition($form)

    $form.ajaxForm
      target: $target
      dataType: 'html'
      success: (data,message,xhr) ->
        if xhr.getResponseHeader('x-flash-errors') != null
          $target.html(data)
          validateSearchCondition($form)
        else
          location.reload()

  $('.question_id_search').livequery ->
    $(this).select2()
    $searchConditionForm = $(this).closest('form')
    $valuesContainer     = $searchConditionForm.find('.search-condition-values')
    $submitButton        = $searchConditionForm.find('button[type="submit"]')

    $(this).on 'change', () ->
      $selectedQuestion = $(this).find('option:selected')
      if $selectedQuestion.length
        $.ajax({
          type: "GET"
          url: $valuesContainer.attr('data-source')
          data:
            question_id: $selectedQuestion.attr('value')
          dataType: 'html'
        }).done (data) ->
          $valuesContainer.html(data)
          $submitButton.enable()
          validateSearchCondition($searchConditionForm)
      else
        $valuesContainer.html('')
        $submitButton.disable


  $('.question_list').livequery ->
    $tableElement = $(this)

    table = $tableElement.dataTable
      bScrollCollapse: true
      sPaginationType: "bootstrap"
      sDom: "<'row-fluid'<'span6'i><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>"
      sWrapper: "dataTables_wrapper form-inline"
      aaSorting: []
      aoColumnDefs: [{ 'bSortable': false, 'aTargets': [ 5 ] }]
      bFilter: true
      iDisplayLength: 30
      bLengthChange: false
      # scrollY: true
      oLanguage: { sSearch: "Filter:&nbsp;" }
      paging: false

  $('.question_lookup').livequery ->
    $(this).on 'click', () ->
      $(this).closest('.row-fluid').find('#question_list').modal('show')
      false

  $('.select_question').livequery ->
    $(this).on 'click', () ->
      $selectQuestionButton = $(this)
      $questionDropdown = $selectQuestionButton.closest('form').find('.question_id_search')
      $.each $questionDropdown.find('option'), () ->
        if $(this).val() == $selectQuestionButton.attr('data-value')
          $(this).attr('selected', 'selected')
        else
          $(this).removeAttr('selected')
      false
      $questionDropdown.trigger('change')

  $('.search-condition-group-operator').livequery ->
    $(this).on 'change', () ->
      $(this).closest('form').submit()

  $('.date-format-link').livequery ->
    $(this).on 'click', () ->
      $container = $(this).closest('.search-condition-answer')
      $container.find('input[type="text"]').val('')
      $container.addClass('hidden')
      $container.siblings().removeClass('hidden')
      $container.siblings().find('input[type="text"]').val('')
      validateSearchCondition($(this).closest('form'))

  validateSearchCondition = (form) ->
    $(form).validate({
      errorPlacement: (error, element) ->
        error.appendTo( element.parent("div"))
    })
    $('#form').submit($(form).valid())

