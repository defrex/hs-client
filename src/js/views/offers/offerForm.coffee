
dep.require 'hs.View'
dep.require 'hs.v.mods.form'
dep.require 'hs.v.mods.authForm'
dep.require 'hs.v.mods.dialog'

dep.provide 'hs.v.OfferForm'


class hs.v.OfferForm extends hs.View

  focusSelector: '.offer-button'

  amount: ->
    parseInt parseFloat(this.get('amount').replace '$', '')*100


  validateAmount: (clbk) -> clbk !_.isNaN(this.amount()), 'Needs to be a number'


  createMessage: (amount, offerId) ->
    this.options.listing.myConvo (convo) =>
      if convo?
        name = zz.auth.curUser().name || 'Anonymous'
        zz.create.message
          message: "#{name} made an offer for $#{amount/100}!"
          convo: convo._id
          offer: offerId

      else
        zz.create.convo listing: this.options.listing, (id) =>
          # this line should be deleted pending the fix of:
          #   https://www.pivotaltracker.com/story/show/16308701
          zz.data.convo id, =>

            this.template.parent.newConvo()
            this.createMessage amount, offerId


  submit: (clbk)->
    this.options.listing.myOffer (offer) =>

      if offer?
        zz.update.offer offer, amount: this.amount(), =>
          this.createMessage(this.amount(), offer._id)
          this.clear()
          this.blur()
          clbk?()


      else
        zz.create.offer
          amount: this.amount()
          listing: this.options.listing._id
          (id) =>
            this.createMessage(this.amount(), id)
            this.clear()
            this.blur()
            clbk?()


hs.v.mods.form hs.v.OfferForm
hs.v.mods.authForm hs.v.OfferForm
hs.v.mods.dialog hs.v.OfferForm
