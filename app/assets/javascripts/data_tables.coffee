ready = ->
  return if $('.datatable').size() == 0

  dataTable = $('.datatable').DataTable
    paging: false
    searching: true
    bInfo: false
    order: []

  active_filter = $(".datatable-filters li.active a").data('filter')
  dataTable.columns([-1]).search(active_filter).draw()

  handleFilterClick = (e) ->
    e.preventDefault()
    filter = $(this).data('filter')
    $parent = $(this).parent()
    $parent.siblings('li').removeClass('active')
    $parent.addClass('active')
    dataTable.columns([-1]).search(filter).draw()

  $('.datatable-filters a').click handleFilterClick

$(document).on 'page:load', ready
$(document).ready ready
