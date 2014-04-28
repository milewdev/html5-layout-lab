draggable = { 
  containment: ".lab", 
  revert: true, 
  revertDuration: 200,
  start: -> 
    $(this).addClass("dragging")
    $( ".target" ).css("visibility", "visible")
  stop: -> 
    $(this).removeClass("dragging")
    $( ".target" ).css("visibility", "hidden")
}

# drop must be defined before droppable so that the circular references work
drop = (event, ui) ->
  $( ui.draggable.data("html") )                        # create a new element from the draggable's html data, e.g. "<header></header>"
    .droppable(droppable)                               # the new element can be a drop target
    .data({ accept: ui.draggable.data("accept") })      # copy the list of acceptable draggables from the draggable itself
    .appendTo(this)                                     # insert the new element into the current drop target
  $(this).removeClass("drop-target")                    # TODO: remove from all child elements in the workbench

droppable = {
  greedy: true,
  over: -> $(this).addClass("drop-target"),
  out: -> $(this).removeClass("drop-target"),
  drop: drop,
  accept: (draggable) -> 
    tagName = draggable.prop("tagName").toLowerCase()   # tag name of element being dragged
    acceptList = $(this).data("accept") ? []            # list of tag names that drop target accepts
    tagName in acceptList
}

$( ".toolbox header" ).data({ html: "<header></header>" })
$( ".toolbox section" ).data({ html: "<section></section>", accept: ["header"] })
$( ".workbench" ).data({ accept: ["header", "section"] })

$( ".toolbox header, .toolbox section" ).draggable(draggable)
$( ".workbench" ).droppable(droppable)
