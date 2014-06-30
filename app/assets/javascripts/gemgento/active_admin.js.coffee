#= require active_admin/base

$(document).ready ->
  console.log 'every page'
  $('select').wrap("<div class='styled_select'></div>")

  if $('body').hasClass('logged_out') && $('#login h2').text() != 'Forgot your password?'
    console.log 'log in page'
    # create placeholders
    $('#admin_user_email_input label').remove()
    $('#admin_user_email_input input').attr('placeholder', 'email')
    $('#admin_user_password_input label').remove()
    $('#admin_user_password_input input').attr('placeholder', 'password')

    # re-organize form actions
    $('#admin_user_submit_action').detach().insertBefore('#admin_user_remember_me_input')
    $('#login a').html('forgot password?')

  else if $('body').hasClass('logged_out') && $('#login h2').text() == 'Forgot your password?'
    console.log 'forgot password page'
    $('#admin_user_email_input label').remove()
    $('#admin_user_submit_action').detach().insertAfter('#admin_user_email_input')
    $('#admin_user_email_input input').attr('placeholder', 'email')
    $('#login a').css 'margin', '1px 0'
    $('#login a').css 'text-align', 'center'
    $('#login a').css 'width', '100%'

jQuery ->
  if $('body').hasClass('admin_product_positions')
    $('#feed-blocks-admin').sortable()
    $('#feed-blocks-admin').disableSelection()
    $('a#submit-product-positions').click (event) ->
      event.preventDefault()
      $.post($(this).attr('href'), $('#feed-blocks-admin').sortable('serialize'))
      alert('Product category positions changes are being updated.  Please do no not update category positions again, until you see all previous changes on the front end.  This process can take up to 5 minutes, depending on how many position changes were needed.')
      return false

    $('#category-select').change ->
      window.location = window.location.href.split('?')[0] + '?category_id=' + $(this).val()