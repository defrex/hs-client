
dep.require 'hs.Template'
dep.provide 'hs.t.Listing'

class hs.t.Listing extends hs.Template

  template: ->
    div class: 'inquiry', id: "inquiry-#{this.model._id}", ->
      span class: 'created'
      div class: 'question'
      div class: 'answer'
      div class: 'clicky'


  subTemplates:
    user:
      class: hs.t.InlineUser


  setCreator: ->
    zz.data.creator this.model.creator, (creator) =>
      this.userTmpl creator, prependTo: "inquiry-#{this.model._id}"


  setQuestion: ->
    this.$('.question').text "Q:#{this.model.question}"


  setAnswer: ->
    this.$('.answer').text "A:#{this.model.answer}"


  setCreated: ->
    since = _.since this.model.created
    this.$('.created').text "#{since.num} #{since.text}"
