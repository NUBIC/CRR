$(document).ready ->
  # ---------------- index page ----------------
  $('#search table#search_index_table').livequery ->
    $tableElement = $(this)

    $tableElement.dataTable
      bScrollCollapse: true
      sPaginationType: "bootstrap"
      sDom: "<'row-fluid'<'span6 data-table-info-header'><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
      sWrapper: "dataTables_wrapper form-inline"
      aaSorting: [[ 1, "asc" ]]
      bFilter: true
      iDisplayLength: 30
      bLengthChange: false
      oLanguage: { sSearch: "Filter:&nbsp;" }
      fnInitComplete: (oSettings, json)  ->
        setTableHeader($tableElement)

  # ---------------- show/edit page ----------------
  # display results
  $('#search table#search_result_list').livequery ->
    $tableElement = $(this)
    aoColumnDefs = []
    if $tableElement.data('selectable')
      aoColumnDefs = [{ 'bSortable': false, 'aTargets': [ 0 ] }]

    table = $tableElement.dataTable
      bScrollCollapse: true
      sPaginationType: "bootstrap"
      sDom: "<'row-fluid'<'span6 data-table-info-header'><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
      sWrapper: "dataTables_wrapper form-inline"
      aaSorting: []
      aoColumnDefs: aoColumnDefs
      bFilter: true
      iDisplayLength: 30
      bLengthChange: false
      oLanguage: { sSearch: "Filter:&nbsp;" }
      fnInitComplete: (oSettings, json)  ->
        setTableHeader($tableElement)

    showHideMore(table.fnGetNodes(), true)

    $releaseButton                = $('#release')
    releaseButtonText             = $releaseButton.html()
    $returnUIContainer            = $('#participant-return-ui')
    $returnUIContainerHeader      = $returnUIContainer.find('.row-group-header')
    $returnUIContainerBody        = $returnUIContainer.find('.row-group')
    returnUIContainerHeaderText   = $returnUIContainerHeader.html()
    $checkboxes                   = $('.selectalloption', table.fnGetNodes()).not(':disabled')
    $submitReturnButton           = $returnUIContainerBody.find('input[type="submit"]')
    $studyInvolvementStatusSelect = $('#study_involvement_status')

    # Match minimal height of the return UI container to participants table
    returnUIContainerHeaderTotalHeight  = $returnUIContainerHeader.height() + parseInt($returnUIContainerHeader.css('padding-top')) + parseInt($returnUIContainerHeader.css('padding-bottom'))
    returnUIContainerBodyPadding        = parseInt($returnUIContainerBody.css('padding-top')) + parseInt($returnUIContainerBody.css('padding-bottom'))
    $returnUIContainerBody.css('min-height', $('#search_result_list_wrapper').height() - returnUIContainerHeaderTotalHeight - returnUIContainerBodyPadding)

    # "Release" button functionality. Disable button unless there is a selected participant
    setReleaseButton = () ->
      $releaseButton.attr('disabled', !$checkboxes.is(':checked'))
      count = $checkboxes.filter(":checked").length
      label = ' participant'
      if count != 1
        label = label + 's'
      $releaseButton.html(releaseButtonText + ' ' + $checkboxes.filter(":checked").length + ' ' + label)

    # Return UI functionality: hide content if participants are not selected
    setReturnUIVisibility = () ->
      $returnUIContainerBody.contents().attr('hidden', !$checkboxes.is(':checked'))
      if $checkboxes.is(':checked')
        $returnUIContainerHeader.html(returnUIContainerHeaderText)
      else
        $returnUIContainerHeader.html($returnUIContainerHeader.data('placeholder'))

    # Return UI functionality: disable submit button until state is selected
    setSubmitReturnButton = () ->
      $submitReturnButton.attr('disabled', $studyInvolvementStatusSelect.find('option:selected').val().length == 0)

    setReleaseButton()      if $releaseButton.length
    setReturnUIVisibility() if $returnUIContainer.length
    setSubmitReturnButton() if $submitReturnButton.length

    $studyInvolvementStatusSelect.on 'change', () ->
      setSubmitReturnButton()

    # 'selectall' checkboxes are reused in release and return workflows.
    $('#selectall').on 'click', () ->
      $checkboxes.prop('checked', $(this).is(':checked'))
      setReleaseButton() if $releaseButton.length
      setReturnUIVisibility() if $returnUIContainer.length

    $checkboxes.on 'click', () ->
      $('#selectall').prop('checked', $checkboxes.filter(':checked').length == $checkboxes.length)
      setReleaseButton() if $releaseButton.length
      setReturnUIVisibility() if $returnUIContainer.length

    # append hidden checkboxes to the release forrm on submit
    $('form.search_result_release_form').on 'submit', () ->
      $checkboxes.appendTo(this);

  # Extended release UI
  $('#approve_return').on 'shown', () ->
    $tableElement = $(this).find('table#extend_release_list')

    if !$.fn.DataTable.isDataTable($tableElement)
      table = $tableElement.dataTable
        scrollY: '150px'
        scrollCollapse: true
        paging: false
        sDom: "<'row-fluid'<'span6 data-table-info-header'><'span6'f>r>t"
        sWrapper: "dataTables_wrapper form-inline"
        aaSorting: [[ 1, "asc" ]]
        aoColumnDefs: [{ 'bSortable': false, 'aTargets': [ 0 ] }]
        bFilter: true
        oLanguage: { sSearch: "Filter:&nbsp;" }
        fnInitComplete: (oSettings, json)  ->
          setTableHeader($tableElement)
      table.fnAdjustColumnSizing()
    else
      table = $tableElement.DataTable();

    $extendReleaseCheckboxes  = $('.selectalloption', table.fnGetNodes()).not(':disabled')
    $extendReleaseButton      = $(this).find('input[type="submit"]#submit_extended_release')
    extendReleaseButtonText   = $extendReleaseButton.val()

    setExtendReleaseButton = () ->
      $extendReleaseButton.attr('disabled', !$extendReleaseCheckboxes.is(':checked'))
      count = $extendReleaseCheckboxes.filter(":checked").length
      label = ' participant'
      if count != 1
        label = label + 's'
      $extendReleaseButton.val(extendReleaseButtonText + ' ' + $extendReleaseCheckboxes.filter(":checked").length + ' ' + label)

    $('#selectall_extend').on 'click', () ->
      $extendReleaseCheckboxes.prop('checked', $(this).is(':checked'))
      setExtendReleaseButton()

    $extendReleaseCheckboxes.on 'click', () ->
      $('#selectall_extend').prop('checked', $extendReleaseCheckboxes.filter(':checked').length == $extendReleaseCheckboxes.length)
      setExtendReleaseButton()

    setExtendReleaseButton()

  # Edit page -- search UI
  $('.btn-search-condition-add').livequery ->
    $(this).on 'click', () ->
      $('.search-instructions').hide()
      $('.search-conditions').show()

  $('.btn-search-condition-group-add').livequery ->
    $(this).on 'click', () ->
      $('.search-instructions').hide()
      $('.search-condition-groups').show()

  # use ajax to deliver edit/new forms, force reload page on success
  $(".search-conditions form.ajax-edit-form").livequery ->
    $form   = $(this)
    $target = $($form.attr('data-target'))

    $form.ajaxForm
      target: $target
      dataType: 'html'
      beforeSubmit: (arr, $form, options) ->
        validateSearchCondition($form)
        $form.valid()
      success: (data,message,xhr) ->
        if xhr.getResponseHeader('x-flash-errors') != null
          $target.html(data)
        else
          location.reload()

  # Search conditions autocompleter/dropdown initialization
  $('.question_search').livequery ->
    $selectElement        = $(this);
    $searchConditionForm  = $selectElement.closest('form');
    $submitButton         = $searchConditionForm.find('button[type="submit"]');
    $valuesContainer      = $searchConditionForm.find('.search-condition-values');

    perPage = 30;

    $selectElement.select2
      ajax:
        url: $selectElement.attr('data-url')
        delay: 250
        dataType: 'json'
        data: (params) ->
          return {
            query: params.term, # search term
            page:  params.page,
            per_page: perPage
          };
        processResults: (data, params) ->
          params.page = params.page || 1;
          return {
            results: data.data,
            pagination: {  more: (params.page * perPage) < data.recordsTotal }
          }
        cache: true
      escapeMarkup: (markup) ->
        return markup; # let our custom formatter work
      templateResult: (el) ->
        if el.search_display
          return '<span class="user-circle"></span><span>' + el.search_display + '</span>';
        else
          return el.text
      templateSelection: (el) ->
        if el.search_display
          return '<span>' + el.search_display + '</span>'
        else
          return el.text

    $selectElement.on 'change', () ->
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
      else
        $valuesContainer.html('')
        $submitButton.disable

  # Popup list of conditions
  $('.question_list').livequery ->
    $tableElement = $(this)

    table = $tableElement.dataTable
      bScrollCollapse:  true
      sDom:             "<'row-fluid'<'span6'i><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>"
      sWrapper:         "dataTables_wrapper form-inline"
      # aaSorting:        []
      # aoColumnDefs:     [{ 'bSortable': false, 'aTargets': [ 5 ] }]
      bFilter:          true
      processing:       true
      bLengthChange:    false
      ordering:         false
      oLanguage:        { sSearch: "Filter:&nbsp;" }
      iDisplayLength:   30
      serverSide:       true
      ajax:             $tableElement.attr('data-source')
      columns: [
        { data: 'survey_title' }
        { data: 'survey_active_flag' }
        { data: 'section_title' }
        { data: 'text' }
        { data: 'answer_values' }
        { data: null, defaultContent: '<button class="select_question">Select</button>' }
      ]

  # Clicking on question list popup button
  $('.question_lookup').livequery ->
    $(this).on 'click', () ->
      $(this).closest('.row-fluid').find('.question-modal-lookup').modal('show')
      false
  # Selecting a question from the popup list
  $('.select_question').livequery ->
    $(this).addClass('button btn btn-success btn-small').attr('data-dismiss', 'modal')
    $(this).on 'click', () ->
      table = $(this).closest('table').dataTable()
      data  = table.fnGetData($(this).closest('tr'))
      $searchConditionForm  = $(this).closest('form')
      $selectElement        = $searchConditionForm.find('select[name="search_condition[question_id]"]');

      $selectedOption = $selectElement.find('option[value="' + data.id + '"]');
      if $selectedOption.length == 0
        $selectedOption = $('<option></option>')
          .val(data.id)
          .html(data.search_display)
        $selectElement.append($selectedOption);
      $selectedOption.attr('selected', 'selected');
      $selectElement.val(data.id).trigger('change');

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

      $searchConditionForm = $(this).closest('form')
      showHideSecondaryAnswer($searchConditionForm)

  # Initialize dataTable on downloads tab
  $('table#downloads_log').livequery ->
    $tableElement = $(this)

    $tableElement.dataTable
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
        setTableHeader($tableElement)

  $('form#new_download').livequery ->
    $form = $(this)
    console.log $form

    $form.on 'submit', () ->
      $(this).validate()
      if $(this).valid()
        $(this).closest('.modal').modal('hide')

  validateSearchCondition = (form) ->
    $(form).validate({
      errorPlacement: (error, element) ->
        error.appendTo( element.parent("div"))
    })
    false

  showHideSecondaryAnswer = ($searchConditionForm) ->
    $selectedOperator = $searchConditionForm.find('.search_condition_operator option:selected')
    if $selectedOperator.length && $selectedOperator.hasClass('operator-cardinality-2')
      $searchConditionForm.find('.secondary-answer-value').removeClass('hidden')
    else
      $searchConditionForm.find('.secondary-answer-value').addClass('hidden')

  $('.search_condition_operator').livequery ->
    $(this).on 'change', () ->
      $searchConditionForm = $(this).closest('form')
      showHideSecondaryAnswer($searchConditionForm)
