remove_targets = ->
  $( ".target" ).remove()

droppable = {
  over: ->
    $(this).addClass("hilight-target")
  out: ->
    $(this).removeClass("hilight-target")
  drop: ->
    $(this)                                             # use target as the element being added:
      .removeClass("target")                            # so that remove_targets() does not remove it
      .removeClass("hilight-target")                    # because 'out' is not called when dropped
      .droppable("disable")                             # no longer a drop target
}

draggable = {
  containment: ".lab"
  helper: ->
    $(this).clone().addClass("dragging")                # drag a clone, leave original in toolbox for next time
  stop: ->
    remove_targets()                                    # remove targets added by 'start' method (see below)
    generate_html()
}

$( ".toolbox header" ).draggable(draggable).draggable({
  start: (event, ui) ->
    targetFactory = $(this).clone().addClass("target")
    parents = $( ".workbench, .workbench > section, .workbench article" )   # the elements we are going to add targets under
      .filter( -> $( "> header", this ).length == 0 )   # exlude elements that already have a header
    parents.each ->
      $(this).prepend( targetFactory.clone().droppable(droppable) )
})

$( ".toolbox footer" ).draggable(draggable).draggable({
  start: ->
    targetFactory = $(this).clone().addClass("target")
    parents = $( ".workbench, .workbench > section" )   # the elements we are going to add targets under
      .filter( -> $( "> footer", this ).length == 0 )   # exlude elements that already have a footer
    parents.each ->
      $(this).append( targetFactory.clone().droppable(droppable) )
})

$( ".toolbox section" ).draggable(draggable).draggable({
  start: ->
    insert_section_targets($(this))
})

$( ".toolbox article" ).draggable(draggable).draggable({
  start: ->
    targetFactory = $(this).clone().addClass("target")
    $( ".workbench > section" ).each ->
      footer = $( "footer", $(this) )[0]
      target = targetFactory.clone().droppable(droppable)
      if footer?
        target.insertBefore(footer)
      else
        target.appendTo( $(this) )
})

# NOTE: order and placement of insertion critical; note use of prependTo() instead of appendTo(), etc.
insert_section_targets = (source) ->
  targetFactory = source.clone().addClass("target")
  header = $( ".workbench > header" )[0]
  footer = $( ".workbench > footer" )[0]
  if $( ".workbench > .left-sidebar").length == 0
    target = targetFactory.clone().addClass("left-sidebar").droppable(droppable)
    if header?
      target.insertAfter(header)
    else
      target.prependTo( $(".workbench") )
  if $( ".workbench > .right-sidebar").length == 0
    target = targetFactory.clone().addClass("right-sidebar").droppable(droppable)
    if header?
      target.insertAfter(header)
    else
      target.prependTo( $(".workbench") )
  if $( ".workbench > .main").length == 0
    target = targetFactory.clone().addClass("main").droppable(droppable)
    if footer?
      target.insertBefore(footer)
    else
      target.appendTo( $(".workbench") )

generate_html = ->
  code = tree($(".workbench"), "    ")
  $( ".html-code pre" ).text( """
<html>

  <head>
  </head>

  <body>
#{code}  </body>

</html>
""" )

tree = (root, indent) ->
  tagName = root.prop('tagName').toLowerCase()
  code = "#{indent}<#{tagName}>" + "\n"
  for child in root.children()
    code += tree($(child), "  " + indent)
  code += "#{indent}</#{tagName}>" + "\n"
  code
