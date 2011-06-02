//depends: main.js, core/data/conn.js

hs.pubsub = {
  subs: {},
  msgId: 0,
  pubRecieved: function(msg) {
    this.trigger('pubRecieved', msg);
    this.trigger('pubRecieved:'+msg.id, msg);
    var key = msg.key;
    if (_.isUndefined(key))
      return hs.error('pub with no key:', msg);
    if (_.isUndefined(this.subs[key]))
      return this.unsub(key);
    _.each(this.subs[key], function(clbk){
      clbk(msg.diff);
    });
  },
  // pub: function(key, data, extra, clbk){
  //   if (_.isFunction(extra))
  //     clbk = extra, extra = {};
  //   return hs.con.send('pub', _.extend({key: key, data: data}, extra), clbk);
  // },
  sub: function(key, handler, clbk, context) {
    var send = _.isUndefined(this.subs[key]);
    if (send) this.subs[key] = new Array();
    if (_.indexOf(this.subs[key], handler) == -1){
      this.subs[key].push(handler);
      if (send) return hs.con.send('sub', {key: key}, clbk, context);
    }
  },
  unsub: function unsub(key, clbk) {
    if (typeof clbk == 'undefined'){
      delete this.subs[key];
      return hs.con.send('unsub', {key: key});
    }else{
      if (_.isUndefined(this.subs[key])) return;
      var i = _.indexOf(this.subs[key], clbk);
      if (i > -1)
        this.subs[key].splice(i, 1);
      if (this.subs[key].length == 0)
        unsub(key);
    }
  }
};
_.extend(hs.pubsub, Backbone.Events);
_.bindAll(hs.pubsub);

hs.con.bind('pub', hs.pubsub.pubRecieved);