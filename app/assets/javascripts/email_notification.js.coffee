$(document).ready ->
  # ---------------- index page ----------------
  $('#email_notification table#email_notification_index_table').livequery ->
    table_element = $(this)
    table_element.dataTable
      bScrollCollapse: true
      sPaginationType: "bootstrap"
      sDom: "<'row-fluid'<'span6 data-table-info-header'><'span6'>r>t<'row'<'span6'i><'span6'p>>"
      sWrapper: "dataTables_wrapper form-inline"
      aaSorting: []
      iDisplayLength: 30
      bLengthChange: false
      columns: [
        null
        null
        null
        null
        { className: "controls_column" },
      ]
      autoWidth: true
      aaSorting: []
      aoColumnDefs: [{ 'bSortable': false, 'aTargets': [ -1 ] }]
      fnInitComplete: (oSettings, json)  ->
        setTableHeader('email_notification', table_element)

  # --------------- edit page -------------------
  $('a.btn-form-submit-with-data').on 'click', () ->
    $form = $(this).closest('form')
    prefix = $(this).data()['prefix']
    values = $(this).data()['values']

    $.each values, (i, v) ->
      $input = $("<input>").attr("type", "hidden").attr("name", prefix + '[' + i + ']').val(v)
      $form.append($input)
    $form.submit()

  $('a.btn-form-submit').on 'click', () ->
    $form = $(this).closest('form')
    $form.submit()

