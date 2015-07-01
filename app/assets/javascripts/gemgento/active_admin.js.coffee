$ ->

  # style select tags
  $('select').wrap("<div class='styled_select'></div>")

  if $('body').hasClass('logged_out') && $('#login h2').text() != 'Forgot your password?'
    # create placeholders
    $('#admin_user_email_input label').remove()
    $('#admin_user_email_input input').attr('placeholder', 'email')
    $('#admin_user_password_input label').remove()
    $('#admin_user_password_input input').attr('placeholder', 'password')

    # re-organize form actions
    $('#admin_user_submit_action').detach().insertBefore('#admin_user_remember_me_input')
    $('#login a').html('forgot password?')

  else if $('body').hasClass('logged_out') && $('#login h2').text() == 'Forgot your password?'
    $('#admin_user_email_input label').remove()
    $('#admin_user_submit_action').detach().insertAfter('#admin_user_email_input')
    $('#admin_user_email_input input').attr('placeholder', 'email')
    $('#login a').css 'margin', '1px 0'
    $('#login a').css 'text-align', 'center'
    $('#login a').css 'width', '100%'


  if $('body').hasClass('admin_product_positions')
    $('#feed-blocks-admin').sortable()
    $('#feed-blocks-admin').disableSelection()
    $('a#submit-product-positions').click (event) ->
      event.preventDefault()
      $('#products').val($('#feed-blocks-admin').sortable('toArray', { attribute: 'data-product-id' }))
      $('#product-positions-form').submit()
      return false

    $('#category-select, #store-select').change ->
      window.location = window.location.href.split('?')[0] + '?category_id=' + $('#category-select').val() + '&store_id=' + $('#store-select').val()