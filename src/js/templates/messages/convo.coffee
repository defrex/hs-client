
dep.require 'hs.Template'
dep.require 'hs.t.MessageForm'
dep.require 'hs.t.Message'

dep.provide 'hs.t.Convo'
dep.provide 'hs.t.ConvoDialog'

class hs.t.Convo extends hs.Template

  template: ->
    div class: 'convo', ->
      div class: 'message-form'
      div class: 'message-list'


  subTemplates:
    message:
      class: hs.t.Message
      prependTo: '.message-list'
    messageForm:
      class: hs.t.MessageForm
      appendTo: '.message-form'


  postRender: ->
    this.messageFormTmpl null,
      convo: this.options.convo
      listing: this.options.listing
      appendTo: "##{this.id} .message-form"


  addModel: (msg, index) ->
    index = undefined if index == -1
    this.messageTmpl msg,
      nthChild: index
      appendTo: "##{this.id} .message-list"


  removeModel: (id, index) ->
    this.removeTmpl index


  newConvo: -> this.parent.newConvo?()

class hs.t.ConvoDialog extends hs.t.Convo