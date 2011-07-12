
dep.require 'hs.Template'

dep.provide 'hs.t.TopBar'



class hs.t.TopBar extends hs.Template

  appendTo: '#top-bar > .width'

  template: ->
    a href: '/about', -> 'About'
    a href: '/how-it-works', -> 'How It Works'
    a href: 'https://getsatisfaction.com/hipsell', target: '_blank', -> 'Feedback'
    a href: '/settings/name', class: 'name'
    a href: '/settings', class: 'settings', -> 'Settings'
    a href: 'javascript:;', class: 'logout', -> 'Logout'
    a href: 'javascript:;', class: 'login', -> 'Login'


  setAuth: (prev, cur) ->
    if cur?
      this.$('.login').hide();
      this.$('.logout').show();
      this.$('.settings').show();

      this.$('.name').html(cur.name || "
          #{localStorage['zz.auth.email']}
          <span id='set-name'>(<span class='red'>
            set public name!
          </span>)</span>
        ").show()

    else
      this.$('.login').show()
      this.$('.logout').hide()
      this.$('.settings').hide()
      this.$('.name').hide().text('')

