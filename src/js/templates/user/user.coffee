
dep.require 'hs.Template'
dep.require 'zz'

dep.provide 'hs.t.User'

class hs.t.User extends hs.Template

  template: ->
    div class: 'user', ->
      div class: 'presence offline'
      img class: 'avatar'
      span class: 'name', -> 'Anonymous'
      div class: 'social', ->
        a target: '_blank', class: 'fb', -> img src: '/img/fb.png'
        a target: '_blank', class: 'twitter', -> img src: '/img/twitter.png'
        a target: '_blank', class: 'linkedin', -> img src: '/img/linkedin.png'


  setName: ->
    this.$('.name').text this.model.name


  setAvatar: ->
    this.$('.avatar').attr 'src', this.model.getAvatarUrl(75)


  setPresence: ->
    node = this.$('.presence').removeClass 'away online offline'

    switch this.model.presence
      when 0
        node.addClass 'offline'
        node.attr 'title', 'Offline'

      when 1
        node.addClass 'online'
        node.attr 'title', 'Online'

      when 2
        node.addClass 'away'
        node.attr 'title', 'Away'


  setFb: ->
    this.$('.fb').attr('href', this.model.fb).show()

  setFb: ->
    this.$('.twitter').attr('href', this.model.twitter).show()

  setFb: ->
    this.$('.linkedin').attr('href', this.model.linkedin).show()
