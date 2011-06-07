//depends: main.js, core/data/sync.js, core/models/fields.js


hs.models = hs.models || new Object();

hs.models.Model = Backbone.Model.extend({
  key: null,
  loaded: false,
  fields: {
    '_id': new hs.models.fields.StringField(),
    'creator': function(){
      return new hs.models.fields.ModelField(hs.auth.models.User);
    },
    'created': new hs.models.fields.DateField(),
    'modified': new hs.models.fields.DateField(),
    'deleted': new hs.models.fields.BooleanField()
  },
  url: function(){return this.key},
  initialize: function(attrs, opts){
    _.bindAll(this);

    if (this._id){
      var success = (opts && opts.success) ? opts.success : undefined;
      var error = (opts && opts.error) ? opts.error : undefined;
      this.fetch({success: success, error: error});
    }else{
      this.once('change:_id', function(){
        this.constructor.register(this);
        this.fetch();
      }, this);
    }

    _.each(this.fields, _.bind(function(field, fieldname){
      if (_.isFunction(field))
        this.fields[fieldname] = field = field.call(this);
      if (field instanceof hs.models.fields.Field){
        field.setModel(this.constructor);
        field.modelInit(this, fieldname);
      }
    }, this));
  },
  set: function(fields, options){
    if (_.isUndefined(options) || options.raw !== true){

      _.each(fields, _.bind(function(value, fieldname){

        if (_.isUndefined(this.fields[fieldname]))
          throw(new Error(fieldname+' is not a '+this.key+' field'));
        else if (this.fields[fieldname] instanceof hs.models.fields.Field)
          fields[fieldname] = this.fields[fieldname].set(value, this, fieldname);

      }, this));

      _.extend(this.updates = this.updates || {}, fields);
      arguments[0] = fields;
    }

    return Backbone.Model.prototype.set.apply(this, arguments)
  },
  get: function(fieldname){
    if (_.isUndefined(this.fields[fieldname]))
      throw(new Error(fieldname+' is not a '+this.key+' field'));

    var value = Backbone.Model.prototype.get.call(this, fieldname);

    if (this.fields[fieldname] instanceof hs.models.fields.Field)
      if (!_.isUndefined(value))
        value = this.fields[fieldname].get(value, this, fieldname);
      else
        value = this.fields[fieldname].getDefault(this, fieldname);

    return value;
  }
});

hs.models.Model.extend = function(){
  var Model = Backbone.Model.extend.apply(this, arguments);

  Model.instances = {};
  Model.get = function(_id, opts){
    if (_.isUndefined(_id)) throw(new Error('cannot get a model without an _id'));

    if (Model.instances.hasOwnProperty(_id))
      return Model.instances[_id];

    var instance = new Model(opts);
    instance.set({_id: _id}, {raw: true});
    Model.instances[_id] = instance;
    return instance;
  };

  Model.register = function(instance){
    this.instances[instance._id] = instance;
  };

  return Model;
};

hs.models.ModelSet = Backbone.Collection.extend({
  cast: function(ids){
    return _.map(ids, function(id){
      return this.model.get(id);
    }, this);
  },
  addIds: function(ids){
    this.add(this.cast(ids));
  },
  removeIds: function(ids){
    this.remove(this.cast(ids));
  },
  addNew: function(ids){
    var newIds = _.select(ids, function(id){
      return _.isUndefined(this.get(id));
    }, this);
    var cast = this.cast(newIds);
    if (cast.length) this.add(cast);
  },
  add: function(models){
    if (_.isArray(models))
      _.each(models, function(model){
        model.bind('change', _.bind(this.trigger, this, 'change'));
      }, this);
    else
      models.bind('change', _.bind(this.trigger, this, 'change'));
    return Backbone.Collection.prototype.add.apply(this, arguments);
  }
});
