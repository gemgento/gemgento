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