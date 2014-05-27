window.App ||= {}
class App.Categories extends App.Base

  constructor: ->
    super
    return this


  index: ->
    # Category#index JS goes here


  show: ->
    $this.sizeTiles()


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

    $('#product-list .product').each ->
      $(this).height(maxHeight)