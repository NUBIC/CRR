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
