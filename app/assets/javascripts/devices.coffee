# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/'


$(document).on 'turbolinks:load', ->
  ### ATM Reset Command ###
  $('#commands-modal').on 'click', '.atm_command_button', (e) ->
    #user click on atm reset button button
    e.preventDefault()
    device_id = $(this).data( "device-id" )
    atm_command = $(this).data( "command" )
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    $.ajax
      url: "/devices/" + device_id + "/send_atm_command"
      dataType: 'json'
      data: 
          command: atm_command
      success: (data) ->
        spinner_icon.hide()
        alert atm_command + " command sent."
        return
      error: ->
        spinner_icon.hide()
        alert 'There was a problem sending the ATM Reset command'
        return
    return
  ### ATM Reset Command ###