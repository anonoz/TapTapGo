$(document).ready ->
  
  # Start websocket connection
  connection = new WebSocket("ws://#{ window.document.location.host }/")

  connection.onopen = ->
    console.log "Websocket Connected"

    # Change the view
    $('#scene0-loading').hide()
    showScene($('#scene1-default'))

    return

  connection.onerror = (x)->
    console.log x

  connection.onmessage = (e)->
    
    # Debugging
    message = JSON.parse e.data
    console.log message

    # Parse status
    if message.status_code == 200 # OK
      
      # Clear last anim
      $('#scene2-success').removeClass('entry exit').hide()
      clearTimeout window.stillExitingScene2

      $('#student_name').text message.content
      showScene($('#scene2-success'))
      
      window.stillExitingScene2 = setTimeout(
        -> hideScene $('#scene2-success')
        3000
      )
    
    else if message.status_code == 404 # User Not Found
      $('#scene4-notfound').show()

    else if message.status_code == 409 # Already Checked In
      $('#scene3-alreadycheckedin').show()

    else # OMG ERROR
      $('#scene5-error').show()

    return

showScene = ($scene)->
  
  # play scene animation
  # Enlarge scene
  $scene.removeClass('exit').show().addClass('entry')

  # Enlarge outer fab
  $scene.find('.outer-fab').addClass('entry')

  # Enlarge icon
  $scene.find('.fab-icon').addClass('entry')

  # Animate text
  $scene.find('h1').addClass('entry')

window.hideScene = ($scene)->
  
  # animate exit
  $scene.addClass('exit').delay(500).hide(0).removeClass('entry')