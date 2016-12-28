ready = ->
  return if $('.datatable').size() == 0

  dataTable = $('.datatable').DataTable
    paging: false
    searching: true
    bInfo: false
    order: []

  active_filter = $(".datatable-filters li.active a").data('filter')
  dataTable.columns([-1]).search(active_filter).draw()
  bindTogglSwitch = ->
    $('input.js-toggle-switch').change (e) ->
      $(this).parent().submit()

  handleFilterClick = (e) ->
    e.preventDefault()
    filter = $(this).data('filter')
    $parent = $(this).parent()
    $parent.siblings('li').removeClass('active')
    $parent.addClass('active')
    dataTable.columns([-1]).search(filter).draw()
    bindTogglSwitch()

  $('.datatable-filters a').click handleFilterClick

  UpdateTableHeaders = ->
    $('.persist-area').each ->
      el = $(this)
      offset = el.offset()
      scrollTop = $(window).scrollTop()
      floatingHeader = $('.floating-header', this)
      if scrollTop > offset.top and scrollTop < offset.top + el.height()
        floatingHeader.css 'visibility': 'visible'
      else
        floatingHeader.css 'visibility': 'hidden'

  $ ->
    clonedHeaderRow = undefined
    $('.persist-area').each ->
      clonedHeaderRow = $('.persist-header', this)
      clonedHeaderRow
        .before(clonedHeaderRow.clone())
        .css('width', clonedHeaderRow.width())
        .addClass('floating-header')
      $('.persist-area').find('tr').first().children().each (i, e) ->
        $($('.floating-header').find('tr').children()[i]).width $(e).width()
    $(window).scroll(UpdateTableHeaders).trigger 'scroll'

$(document).on 'page:load', ready
$(document).ready ready
