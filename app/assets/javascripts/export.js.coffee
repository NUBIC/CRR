$(document).ready ->
  $("#export").livequery ->
    $participantExportTree  = $('.participant-export-options')
    $surveyExportTree       = $('.survey-export-options')
    $exportForm             = $participantExportTree.closest('form')

    $participantExportTree.jstree({
      "plugins" : ["checkbox"]
      "core" : {
        "themes" : {
          "icons": false
          "dots": false
        }
      }
    })
    $surveyExportTree.jstree({
      "plugins" : ["checkbox"],
      "core" : {
        "themes" : {
          "icons": false,
          "dots": false,
        },
        "data" : {
          "url" : $surveyExportTree.attr("data-url"),
          "dataFilter" : (data) ->
            parsedData = JSON.parse(data)
            $.each parsedData, (i, node) ->
              node.data       = {}
              node.data.id    = node.id
              node.data.type  = node.node_type
              node.id         = node.node_unique_id
              node.text       = node.node_text
              node.parent     = node.node_parent
              node.children   = node.has_children
              true
            return JSON.stringify(parsedData)
          "data" : (node) ->
            if node.id.match(/survey_/g)
              return "survey_id" : node.id.split("_")[1]
            if node.id.match(/section_/g)
              return "section_id" : node.id.split("_")[1]
        }
      }
    });

    $('button#export-data').on 'click', () ->
      selectedParams = {};
      checkedParticipantNodes = $participantExportTree.jstree(true).get_top_selected(true)
      checkedSurveyNodes      = $surveyExportTree.jstree(true).get_top_selected(true);

      $exportForm.find('input.export-data-selected-fields-input[type="hidden"]').remove()
      $.each checkedParticipantNodes, (i, node) ->
        $("<input>").attr({
          class: 'export-data-selected-fields-input',
          type:   "hidden",
          id:     node.id,
          name:   node.data.type + '[' + node.data.id + ']',
          value:  node.data.id
        }).appendTo($exportForm);
      $.each checkedSurveyNodes, (i, node) ->
        $("<input>").attr({
          class: 'export-data-selected-fields-input',
          type:   "hidden",
          id:     node.id,
          name:   node.data.type + '[id][]',
          value:  node.data.id
        }).appendTo($exportForm);

      $exportForm.submit