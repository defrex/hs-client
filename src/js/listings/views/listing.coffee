
dep.require 'hs.views.Page'
dep.require 'hs.listings.views'
dep.require 'hs.listings.Listing'
dep.require 'hs.users.views.User'
dep.require 'hs.inquiries.views.Inquiries'
dep.require 'hs.messages.views.ConvoList'
dep.require 'hs.messages.views.Conversation'

dep.provide 'hs.listings.views.Listing'


hs.listings.views.Listing = hs.views.Page.extend
  template: 'listingPage'

  modelEvents:
    'change:creator': 'updateCreator'
    'change:photo': 'updatePhoto'
    'change:description': 'updateDesc'
    'change:created': 'updateCreated'
    'change:modified': 'updateCreated'
    'change:latitude': 'updateLoc'
    'change:longitude': 'updateLoc'
    'change:price': 'updatePrice'
    'change:offers': 'updateBestOffer'
    'change:accepted': 'updateAccepted'
    'change:sold': 'updateSold'


  render: () ->
    hs.views.Page::render.apply this, arguments

    hs.auth.bind 'change:isAuthenticated', this.updateCreator, this

    this.inquiries = new hs.inquiries.views.Inquiries
      appendTo: $('#listing-inquiries')
      model: this.model
    this.inquiries.render()

    this.$('.twitter').html '
      <a href="http://twitter.com/share"
         class="twitter-share-button"
         data-count="horizontal"
         data-via="hipsellapp"
         data-text="Check out this awesome item for sale on Hipsell. Snap it up before it\'s too late.">
          Tweet
      </a>
      <script src="http://platform.twitter.com/widgets.js"></script>'

    this.$('.fb').html '
      <iframe
        src="http://www.facebook.com/plugins/like.php?app_id=105236339569884&amp;href=http%3A%2F%2Fhipsell.com/#!/listings/{{_id}}/&amp;send=true&amp;layout=button_count&amp;width=200&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font&amp;height=30" scrolling="no" frameborder="0"
        style="border:none; overflow:hidden; width:200px; height:30px;" allowTransparency="true">
      </iframe>'

    if Modernizr.geolocation
      navigator.geolocation.getCurrentPosition _.bind(this.updateLocation, this)

    hs.setMeta 'og:title', 'Listing at Hipsell'
    hs.setMeta 'og:type', 'product'
    hs.setMeta 'og:url', window.location.toString()
    hs.setMeta 'og:site_name', 'Hipsell'
    hs.setMeta 'fb:app_id', '110693249023137'


  updateCreator: () ->
    this.creator = this.model.get 'creator'

    if this.creator? and not this.creatorView?
      this.creatorView = new hs.users.views.User
        el: this.$('#listing-creator')
        model: this.creator

      this.creatorView.render()

    hs.auth.ready =>
      if (this.creator? and
          hs.auth.isAuthenticated() and
          this.creator._id == hs.users.User.get()._id and
          not this.convoList?)

        if this.convo?
          this.convo.remove()
          this.convo = null

        this.convoList = new hs.messages.views.ConvoList
          appendTo: $('#listing-messages')
          model: this.model

        this.convoList.render()

      else if not this.convo?

        if this.convoList?
          this.convoList.remove()
          this.convoList = null

        this.convo = new hs.messages.views.Conversation
          appendTo: $('#listing-messages')
          listing: this.model

        this.convo.render()


  updatePhoto: () ->
    if this.model.get('photo')?
      url = "http://#{conf.server.host}:#{conf.server.port}/static/#{this.model.get('photo')}"

      this.$('#listing-image img').attr 'src', url
      hs.setMeta 'og:image', url


  updateDesc: () ->
    if this.model.get('description')?
      this.$('#listing-description').text(this.model.get('description'))
      $('title').text('Hipsell - '+this.model.get('description'))

      hs.setMeta 'og:description', this.model.get('description')


  updateCreated: () ->
    if this.model.get('created')?
      since = _.since this.model.get('created')
      this.$('.date .listing-obi-title').text(since.text)
      this.$('.date .listing-obi-value').text(since.num)


  updateLoc: () ->
    if this.model.get('latitude')? and this.model.get('longitude')?

      lat = this.model.get('latitude')
      lng = this.model.get('longitude')

      this.$('img.map').attr 'src',
        "http://maps.google.com/maps/api/staticmap?center=#{lat},#{lng}&zoom=14&size=340x100&sensor=false"

      this.$('.mapLink').attr 'href',
        "http://maps.google.com/?ll=#{lat},#{lng}&z=16"

      hs.setMeta 'og:latitude', lat
      hs.setMeta 'og:longitude', lng


  updateLocation: (position) ->
    hs.log 'gettings location, listing: ', this.model.get('latitude'), this.model.get('longitude'), ' user: ', position.coords.latitude, position.coords.longitude
    listingLoc = new LatLon this.model.get('latitude'), this.model.get('longitude')
    userLoc = new LatLon position.coords.latitude, position.coords.longitude

    dist = parseFloat userLoc.distanceTo listingLoc
    brng = userLoc.bearingTo listingLoc

    direction = _.degreesToDirection brng

    if dist < 1
      distStr = Math.round(dist*1000)+' metres'
    else
      distStr = Math.round(dist*100)/100+' km'

    this.$('#listing-locDiff').text "Roughly #{distStr} #{direction} of you."


  updatePrice: () ->
    if this.model.get('price')?
      this.$('.asking .listing-obi-value').text('$'+this.model.get('price'))


  updateBestOffer: () ->
    this.model.bestOffer (best) =>
      if best
        node = this.$('.best-offer .listing-obi-value')

        node.text('$'+best.get('amount'))

        node.animate {color: '#828200'}, 250, () ->
          node.animate {color: '#5E5E5E'}, 250

  updateSold: () ->
    if this.model.get('sold')
      this.$('.status').removeClass('accepted').addClass('sold').text('Sold')


  updateAccepted: () ->
    accepted = this.model.get('accepted')
    if accepted?
      this.$('.status').removeClass('sold').addClass('accepted').text('Offer Accepted')
      this.accepted = true
      this.offers.disable(accepted)
      this.inquiries.disable()
    else if this.accepted?
      this.$('.status').hide()
      this.accepted = false
      this.offers.enable()
      this.inquiries.enable()