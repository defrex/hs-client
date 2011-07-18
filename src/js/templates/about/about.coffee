
dep.require 'hs.Template'

dep.provide 'hs.t.About'


class hs.t.About extends hs.Template

  appendTo: '#main'

  template: ->
    div class: 'flatpage', ->
      h1 'About Hipsell'
      p '''
          Hipsell is a mobile and web app that offers a completely new and
          streamlined buying and selling experience. We let you sell things
          right from your phone in one simple step, and leverage cutting-edge
          technology to help you communicate with buyers and sellers as fast
          and painlessly as possible. Seriously. We're so confident in what
          we're building that we'll guarantee you won't find a better way to
          sell or buy things anywhere.
        '''
      p '''
          At the moment we're still in private beta, which means only selected
          users will be able to create new listings.
        '''

      h2 'The Team'
      p 'Hipsell is built by ', ->
        a href: 'http://twitter.com/mattskilly', -> '@mattskilly'
        text ' '
        a href: 'http://twitter.com/defrex', -> '@defrex'
        text ' '
        a href: 'http://twitter.com/lylepstein', -> '@lylepstein'
        text '.'

      h2 'Contact Us'

      p '''
        For feedback, questions, or generally anything related to the site,
        you should visit our <a href="https://getsatisfaction.com/hipsell">
        GetSatisfaction</a> page by clicking the Feedback link above.
      '''

      p '''
        If you need to get in touch with us for other reasons, you can email us
        at <a href="mailto:sold@hipsell.com">sold@hipsell.com</a>.
      '''