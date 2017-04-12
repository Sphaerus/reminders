ready = ->
  $('.js-assign-person').on 'click', (e) ->
    $('.js-assign-person').addClass 'disabled'
    $(e.target).text 'In progress...'

$(document).on 'page:load', ready
$(document).ready ready
