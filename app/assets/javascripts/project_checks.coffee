ready = ->

  $('.js-add-manual-check').attr 'disabled', true
  $('#manual_check_note_url').keyup ->
    if $(this).val().length != 0
      $('.js-add-manual-check').attr 'disabled', false
    else
      $('.js-add-manual-check').attr 'disabled', true

  $('.js-mark-as-done').attr 'disabled', true
  $('#check_assignment_note_url').keyup ->
    if $(this).val().length != 0
      $('.js-mark-as-done').attr 'disabled', false
    else
      $('.js-mark-as-done').attr 'disabled', true

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
