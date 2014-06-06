jQuery ->
  if $('body').hasClass('admin_product_positions')
    $('#feed-blocks-admin').sortable()
    $('#feed-blocks-admin').disableSelection()
    $('a#submit-product-positions').click (event) ->
      event.preventDefault()
      $.post($(this).attr('href'), $('#feed-blocks-admin').sortable('serialize'))
      alert('Product category positions have been updated')
      return false

    $('#category-select').change ->
      window.location = window.location.href.split('?')[0] + '?category_id=' + $(this).val()