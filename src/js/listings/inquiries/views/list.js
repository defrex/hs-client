
dep.require('hs.views.View');
dep.require('hs.inquiries.views');
dep.require('hs.inquiries.views.Inquiry');
dep.require('hs.inquiries.views.QuestionForm');

dep.provide('hs.inquiries.views.Inquiries');

hs.inquiries.views.Inquiries = hs.views.View.extend({
  template: 'inquiries',
  modelEvents: {
    'change:inquiries': 'inquiriesChange'
  },
  render: function(){
    this._tmplContext.inquiries = this.model.get('inquiries').toJSON();
    hs.views.View.prototype.render.apply(this, arguments);
    // this.questionForm = this.questionForm || new hs.inquiries.views.QuestionForm({
    //   appendTo: this.$('#inquiryFormWrap'),
    //   listing: this.model
    // });
    this.renderInquiries();
  },
  inquiryViews: new Object(),
  renderInquiries: function(){
    var newInquiries = this.model.get('inquiries');
    var newInquiryIds = [];
    // add new inquiries
    _.each(newInquiries, _.bind(function(o, i){
      var inquiry = newInquiries.at(i);
      newInquiryIds.push(inquiry._id);
      if (_.isUndefined(this.inquiryViews[inquiry._id])){
        this.inquiryViews[inquiry._id] = new hs.inquiries.views.Inquiry({
          appendTo: $('#inquiryList'),
          model: inquiry
        });
      }
    }, this));
    // remove old inquiries
    _.each(_.keys(this.inquiryViews), _.bind(function(id){
      id = parseInt(id);
      if (!_.include(newInquiryIds, id))
        delete this.inquiryViews[id];
    }, this));
    // render inquiries
    _.each(this.inquiryViews, _.bind(function(view){
      if (!view.rendered) view.render();
    }, this));
  },
  inquiriesChange: function(){
    this.renderInquiries();
  },
  disable: function(){
    this.questionForm.disable();
  },
  enable: function(){
    this.questionForm.enable();
  }
});