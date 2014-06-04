window.App ||= {}
class App.GemgentoProducts extends App.Base

  constructor: ->
    super
    # js to perform on all controller actions goes here
    return this


  index: ->
    # Products#index JS goes here
    return


  show: ->
    $this.manageConfigurableAttributes()
    return


  manageConfigurableAttributes: ->
    $('.configurable-attributes .product-attribute').change ->
      $selector = $(this).find('select')
      $value = JSON.parse($selector.val())
      console.log $value[0]
      $(this).next().find('select').removeAttr('disabled')

    return
