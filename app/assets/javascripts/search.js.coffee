$(document).ready ->
  $('#search table.index').dataTable({
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
      $('.data-table-info-header').html($('.header.hidden').html())
  });