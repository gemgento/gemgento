var updateRegions = {
  init: function( model ) {
      el = $("#" + model +"_country_id")
      el.change(function(){ updateRegions.getRegions(model) });
  },

  getRegions: function(model) {
    el = $("#" + model +"_country_id")
    target_el = $("#" + model +"_region_id")
    $.ajax({
      url: "/addresses/region_options?country_id=" + el.val(),
      dataType: "html",
      success: function(data) {
        target_el.html(data);
      }
    });
  }
};

$(document).ready(function() {
  if ($('#same_as_billing').is(':checked')) {
    $('#shipping_address').hide();
  } else {
    $('#shipping_address').show();
  }

  $('#same_as_billing').click(function() {
    if ($(this).is(':checked')) {
      $('#shipping_address').hide();
    } else {
      $('#shipping_address').show();
    }
  });
});