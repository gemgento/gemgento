window.App ||= {}

App.remoteSubmission = ($form) ->
  $.ajax
    url: $form.attr('action')
    type: $form.attr('method')
    data: $form.serialize()
    dataType: 'json'


App.updateRegions = ($countrySelector, $regionSelector, $regionWrapper) ->

  if $('option', $regionSelector).length > 0
    $regionWrapper.show()
  else
    $regionWrapper.hide()

  $countrySelector.on 'change', ->
    regionRequest = $.get '/addresses/region_options', { country_id: $(this).val() }

    regionRequest.done (result) ->
      $regionSelector.html(result)

      if $('option', $regionSelector).length > 0
        $regionWrapper.show()
      else
        $regionWrapper.hide()

    regionRequest.fail ->
      $regionSelector.html('')
      alert('There was a problem fetching the regions.')