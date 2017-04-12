ready = ->
  return if $('.project-checks-datatable').size() == 0

  dataTable = $('.project-checks-datatable').DataTable
    paging: false
    searching: true
    bInfo: false
    dom: 'lrti'

  handleFilterClick = (e) ->
    e.preventDefault()
    filter = $(this).data('filter')
    $parent = $(this).parent()
    $parent.siblings('li').removeClass('active')
    $parent.addClass('active')
    dataTable.columns([-1]).search(filter).draw()

  $('.project-checks-filters a').click handleFilterClick

  $('input.js-toggle-switch-project-check').change (e) ->
    $(this).parent().submit()

  dataTable.columns([-1]).search('enabled').draw()

$(document).on 'page:load', ready
$(document).ready ready
