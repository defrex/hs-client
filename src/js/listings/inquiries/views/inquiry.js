
dep.require('hs.views.View');
dep.require('hs.inquiries.views');

dep.provide('hs.inquiries.views.Inquiry');

hs.inquiries.views.Inquiry = hs.views.View.extend({
  template: 'inquiry',
  modelEvents: {
    'change:question': 'questionChange',
    'change:answer': 'answerChange',
    'change:creator': 'creatorChange',
    'change:created': 'createdChange'
  },
  initialize: function(){
    hs.views.View.prototype.initialize.apply(this, arguments);
    if (this.model.get('creator'))
      this.creatorChange();
    if (this.model.get('question'))
      this.questionChange();
  },
  render: function(){
    hs.views.View.prototype.render.apply(this, arguments);
    this.initAnswer();
  },
  creatorChange: function(){
    this.creator = this.model.get('creator');
    this.creator.bind('change:avatar', _.bind(this.avatarChange, this));
    this.creator.bind('change:name', _.bind(this.nameChange, this));
    if (this.creator.get('avatar'))
      this.avatarChange();
    if (this.creator.get('name'))
      this.nameChange();

    this.listingOwned = false;
    this.owned = false;
    if (hs.auth.isAuthenticated()){
      var userId = hs.users.User.get()._id;
      if (this.creator._id == userId){
        this.owned = true;
      }
      this.model.withRel('listing.creator', function(listingCreator){
        if (listingCreator._id == userId){
          this.listingOwned = true;
          this.controlsChange();
        }
        }, this);
    }
    this.controlsChange();
  },
  controlsChange: function(){
    if (this.owned){
      // TODO: edit question
    }
    this.initAnswer();
  },
  initAnswer: function(){
    if (this.listingOwned && this.rendered){
      this.el.addClass('canAnswer');
      this.$('.ansButton').show();
      this.answerForm = this.answerForm || new hs.inquiries.views.AnswerForm({
        model: this.model,
        focusSelector: '#inquiry-'+this.model._id,
        appendTo: this.el
      });
    }
  },
  questionChange: function(){
    this.$('.question').text('Q: '+this.model.get('question'));
  },
  answerChange: function(){
    this.$('.answer').text('A: '+this.model.get('answer'));
  },
  avatarChange: function(){
    this.$('.avatar').attr('src', this.creator.getAvatarUrl(30));
  },
  nameChange: function(){
    if (this.creator.get('name'))
      this.$('.name').text(this.creator.get('name'));
  },
  createdChange: function(){
    var since = _.since(this.model.get('created'));
    this.$('.created').text(since.num+' '+since.text);
  },
  accept: function(e){
    e.preventDefault();
    this.model.accept();
  },
  answer: function(e){
    e.preventDefault();
    this.model.del();
  },
  remove: function(){
    $('#inquiry-'+this.model._id).remove();
    this.trigger('removed');
  }
});