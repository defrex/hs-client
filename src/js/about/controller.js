
hs.require('hs.Controller');
hs.require('hs.about.views.About');
hs.require('hs.about.views.How');

hs.regController('about', hs.Controller.extend({
  routes: {
    '!/about/': 'about',
    '!/how-it-works/': 'how'
  },
  about: function(){
    hs.page.finish();
    hs.page = new hs.about.views.About();
    hs.page.render();
  },
  how: function(){
    hs.page.finish();
    hs.page = new hs.about.views.How();
    hs.page.render();
  }
}));
