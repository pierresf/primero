_primero.Views.DateRangeControl = Backbone.View.extend({
  el: '.page_content form',
  events: {
    'change div.date_or_date_range_selector input[type="radio"]' : 'change_date_or_date_range'
  },

  initialize: function() {
    $('div.date_or_date_range_selector input[type="radio"]').each(function(){
      radio = $(this);
      if (radio.is(':checked')) {
        if (radio.val() == "date") {
          radio.parent().parent().find('div.date').removeAttr('style');
          radio.parent().parent().find('div.date_range').attr('style', 'display:none;');
        }
        else if (radio.val() == "date_range") {
          radio.parent().parent().find('div.date').attr('style', 'display:none;');
          radio.parent().parent().find('div.date_range').removeAttr('style');
        }
      }
    });
  },

  change_date_or_date_range: function(event) {
    radio = $(event.target);
    if (radio.is(':checked')) {
      if (radio.val() == "date") {
        radio.parent().parent().find('div.date').removeAttr('style');
        radio.parent().parent().find('div.date_range').attr('style', 'display:none;');
        radio.parent().parent().find('div.date_range input.form_date_field').val("");
      }
      else if (radio.val() == "date_range") {
        radio.parent().parent().find('div.date').attr('style', 'display:none;');
        radio.parent().parent().find('div.date_range').removeAttr('style');
        radio.parent().parent().find('div.date input.form_date_field').val("");
      }
    }
  }
});