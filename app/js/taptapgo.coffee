$(document).ready ->
  
  # Start websocket connection
  connection = new WebSocket("ws://#{ window.document.location.host }/")

  connection.onopen = ->
    console.log "Websocket Connected"

    # Change the view
    $(".scene").hide()
    $("#scene1-default").show()

    return

  connection.onerror = (x)->
    console.log x

  connection.onmessage = (e)->
    
    # Debugging
    message = JSON.parse e.data
    console.log message

    $('.scene').hide()

    # Parse status
    if message.status_code == 200 # OK
      $('#scene2-success').show()
      $('#student_name').text message.content
    
    else if message.status_code == 404 # User Not Found
      $('#scene4-notfound').show()

    else if message.status_code == 409 # Already Checked In
      $('#scene3-alreadycheckedin').show()

    else # OMG ERROR
      $('#scene5-error').show()

    return