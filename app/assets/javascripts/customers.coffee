# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).on 'turbolinks:load', ->
    $('a[data-toggle="tab"]').on 'show.bs.tab', (e) ->
      #save the latest tab
      localStorage.setItem 'lastTab', $(e.target).attr('href')
      return
    #go to the latest tab, if it exists:
    lastTab = localStorage.getItem('lastTab')
    if lastTab
      $('a[href="' + lastTab + '"]').click()
    return