ready = ->
  $(".js-datepicker").datepicker
    format: "dd/mm/yyyy",
    startDate: "0"

$(document).on "page:load", ready
$(document).ready ready
