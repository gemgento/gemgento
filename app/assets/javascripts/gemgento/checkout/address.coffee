window.App ||= {}
class App.GemgentoCheckoutAddress extends App.Base

  beforeAction: =>
    toggleAddress()
    addressTypes = ['billing' , 'shipping']
    for addressType in addressTypes
      $countrySelector = $("#quote_#{addressType}_address_attributes_country_id")
      $regionSelector = $("#quote_#{addressType}_address_attributes_region_id")
      $regionWrapper = $regionSelector.parent()
      App.updateRegions( $countrySelector, $regionSelector, $regionWrapper)

    $('#same_as_billing').on 'change', ->
      toggleAddress()

  toggleAddress = ->
    if $('#same_as_billing').is(':checked')
      $('#shipping_address').hide()
    else
      $('#shipping_address').show()
