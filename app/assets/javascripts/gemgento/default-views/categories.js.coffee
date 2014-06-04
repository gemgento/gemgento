window.App ||= {}
class App.GemgentoCategories extends App.Base

  constructor: ->
    super
    # js to perform on all controller actions goes here
    return this


  index: ->
    # Category#index JS goes here
    return


  show: ->
    $this.sizeTiles()
    return


  sizeTiles: ->
    maxHeight = 0

    $('#product-list .product').each ->
      size = $(this).find('img').data('size').split('x')
      width = size[0]
      height = size[1]
      ratio = height / width
      newHeight = ratio * $(this).width()

      if newHeight > maxHeight
        maxHeight = newHeight

      return

    $('#product-list .product').each ->
      $(this).height(maxHeight)
      return

    return