//depends: offers/views/main.js, core/views/forms/dialog.js

hs.offers.views.Form = hs.views.AuthFormDialog.extend({
  template: 'offerForm',
  focusFieldName: 'offer',
  fields: [{
    'name': 'amount',
    'type': 'text',
    'placeholder': 'Make an Offer'
  }].concat(hs.views.AuthFormDialog.prototype.fields),
  events: _.extend({
    'focus [name=amount]': 'amountFocus',
    'blur [name=amount]': 'amountBlur'
  }, hs.views.AuthFormDialog.prototype.events),
  initialize: function(opts){
    hs.views.AuthFormDialog.prototype.initialize.apply(this, arguments);
    this.listing = opts.listing;
    this.model = new hs.offers.Offer({
      listing: this.listing.id
    });
  },
  amountFocus: function(){
    if (this.$('[name=amount]').val() == '')
      this.$('[name=amount]').val('$');
  },
  amountBlur: function(){
    if (this.$('[name=amount]').val() == '$')
      this.$('[name=amount]').val('');
  },
  focus: function(){
    hs.views.AuthFormDialog.prototype.focus.apply(this, arguments);
    this.$('[name=amount]').focus();
  },
  validateAmount: function(value, clbk){
    clbk(/^\d+$/.test(value.replace('$', '')));
  },
  submit: function(){
    this.model.set({
      creator: hs.auth.getUser(),
      created: new Date(),
      amount: this.get('amount').replace('$', '')
    });
    this.model.save();
    this.clear();
    this.model = new hs.offers.Offer({
      listing: this.listing.id
    });
    this.blur();
  }
});
