
dep.require 'hs.Template'
dep.require 'zz'
dep.require 'hs.t.User'
dep.require 'hs.t.Inquiries'
dep.require 'hs.t.Convo'
dep.require 'hs.t.ConvoList'
dep.require 'hs.t.OfferForm'
dep.require 'hs.t.Offers'

dep.provide 'hs.t.Listing'


class hs.t.Listing extends hs.Template

  appendTo: '#main'

  template: ->
    div class: 'listing clearfix', ->

      div class: 'section-left', ->
        div id: 'listing-image', -> img()
        div id: 'listing-messages', class: 'list-box', ->
          h2 -> 'Ask A Question'

      div class: 'section-right', ->
        div id: 'listing-details', ->
          div id: 'listing-creator'
          span class: 'status', => 'Available'
          div id: 'listing-description'
          div id: 'created'
          div class: 'bottom', ->
            div id: 'listing-social', ->
              div class: 'twitter'
              div class: 'fb'
              div class: 'goog'

            div id: 'listing-loc-diff'

            a href: 'javascript:;', class: 'map-link', target: '_blank', ->
              img class: 'map'

            div class: 'offer-form-wrapper', ->
              div class: 'button offer-button', -> 'Make an Offer'


        div id: 'listing-inquiries', class: 'list-box', ->
          h2 -> 'Frequently Asked Questions'


  subTemplates:
    user:
      class: hs.t.User
      appendTo: '#listing-creator'

    inquiries:
      class: hs.t.Inquiries
      appendTo: '#listing-inquiries'

    convo:
      class: hs.t.Convo
      appendTo: '#listing-messages'

    convoList:
      class: hs.t.ConvoList
      appendTo: '#listing-messages'

    offerForm:
      class: hs.t.OfferForm
      appendTo: '.offer-form-wrapper'

    offers:
      class: hs.t.Offers
      appendTo: '.listing .bottom'


  postRender: ->
    this.model.relatedInquiries this.inquiriesTmpl
    this.model.relatedOffers (offers) =>
      this.offersTmpl offers, listing: this.model

    this.$('#listing-social .twitter').html '
      <a href="http://twitter.com/share"
         class="twitter-share-button"
         data-count="none"
         data-via="hipsellapp"
         data-text="Check out this awesome item for sale on Hipsell. Snap it up before it\'s too late.">
          Tweet
      </a>
      <script src="http://platform.twitter.com/widgets.js"></script>'

    this.$('#listing-social .fb').html "
      <iframe src=\"http://www.facebook.com/plugins/like.php?app_id=105236339569884&amp;href=http%3A%2F%2Fhipsell.com/#!/listings/#{this.model._id}/&amp;href&amp;send=false&amp;layout=standard&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font&amp;width=55&amp;height=24\" scrolling=\"no\" frameborder=\"0\" style=\"border:none; overflow:hidden; width:55px; height:24px;\" allowTransparency=\"true\"></iframe>"

    this.$('#listing-social .goog').html '
      <script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script>
      <g:plusone size="medium" count="false"></g:plusone>'

    this.meta property: 'og:title', content: 'Listing at Hipsell'
    this.meta property: 'og:type', content: 'product'
    this.meta property: 'og:url', content: window.location.toString()
    this.meta property: 'og:site_name', content: 'Hipsell'
    this.meta property: 'fb:app_id', content: '110693249023137'


  setAuth: (prev, cur) ->
    this.offerFormTmpl.remove()
    this.newConvo()

    if not cur? or this.model.creator != cur._id
      this.$('.offer-button').show()
      this.$('.bottom').css 'height': 255

      this.offerFormTmpl null, listing: this.model

    else
      this.$('.offer-button').hide()
      this.$('.bottom').css 'height': 210


  newConvo: ->
    this.convoTmpl.remove()
    this.convoListTmpl.remove()

    user = zz.auth.curUser()

    if user? and this.model.creator == user._id
      this.$('#listing-messages h2').text 'Buyer Messages'

      this.model.relatedConvos =>
        this.convoListTmpl.apply(this, arguments)

    else
      this.$('#listing-messages h2').text 'Ask A Question'
      this.model.myConvo (convo) =>
        if convo?
          convo.relatedMessages (messages) =>
            this.convoTmpl messages, convo: convo, listing: this.model
        else
          this.convoTmpl null, listing: this.model


  setCreator: () ->
    zz.data.user this.model, 'creator', (creator) =>
      this.userTmpl creator


  setPhoto: () ->
    url = "http://#{conf.zz.server.host}:#{conf.zz.server.port}/static/#{this.model.photo}"
    this.$('#listing-image > img').attr 'src', url


  setDescription: () ->
    this.$('#listing-description').text this.model.description
    $('title').text "Hipsell - #{this.model.description}"
    this.meta property: 'og:description', content: this.model.description


  setCreated: () ->
    since = _.since this.model.created
    this.$('.created').text "#{since.num} #{since.text}"


  setPrice: () ->
    this.$('.asking.value').text "$#{this.model.price}"


  setLongitude: -> this.setLocation.apply this, arguments
  setLatitude: -> this.setLocation.apply this, arguments
  setLocation: () ->
    lat = this.model.latitude
    lng = this.model.longitude

    this.$('img.map').attr 'src',
      "http://maps.google.com/maps/api/staticmap?center=#{lat},#{lng}&zoom=14&size=380x100&sensor=false"

    this.$('.mapLink').attr 'href',
      "http://maps.google.com/?ll=#{lat},#{lng}&z=16"

    this.meta property: 'og:latitude', content: lat
    this.meta property: 'og:longitude', content: lng

    if Modernizr.geolocation
      navigator.geolocation.getCurrentPosition =>
        this.updateLocation.apply(this, arguments)


  updateLocation: (position) ->
    this.lat ?= position.coords.latitude
    this.lng ?= position.coords.longitude

    listingLoc = new LatLon this.model.latitude, this.model.longitude
    userLoc = new LatLon this.lat, this.lng

    dist = parseFloat userLoc.distanceTo listingLoc
    brng = userLoc.bearingTo listingLoc

    direction = _.degreesToDirection brng

    if dist < 1
      distStr = Math.round(dist*1000)+' metres'
    else
      distStr = Math.round(dist*100)/100+' km'

    this.$('#listing-loc-diff').text "Roughly #{distStr} #{direction} of you."



hs.t.Listing.getModel = (options, clbk) ->
  zz.data.listing options.parsedUrl[0], clbk
