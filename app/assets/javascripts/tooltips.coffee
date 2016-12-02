ready = ->
  $('[data-toggle="tooltip"]').tooltip()

$(document).on 'page:load', ready
$(document).ready ready
