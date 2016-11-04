$(document).ready ->
  # Index page
    $('#surveys_index_table').livequery ->
      $tableElement = $(this)

      table = $tableElement.dataTable
        bScrollCollapse: true
        sPaginationType: "bootstrap"
        sDom: "<'row-fluid'<'span6 data-table-info-header'><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
        sWrapper: "dataTables_wrapper form-inline"
        aaSorting: [0, "asc"]
        bFilter: true
        iDisplayLength: 30
        bLengthChange: false
        oLanguage: { sSearch: "Filter:&nbsp;" }
        fnInitComplete: (oSettings, json)  ->
          setTableHeader($tableElement)

