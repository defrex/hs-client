//depends: main.js

(function(){
  var initStack = new Array(),
    initFired = false;

  hs.init = function(func, that){
    if (initFired) func.call(that);
    else initStack.push(_.bind(func, that));
  }

  $(function(){
    var init = function(){
      hs.log('init')
      initFired = true;
      for (var i=0, len=initStack.length; i<len; i++)
        initStack[i]();
    }

    init();

    window.applicationCache.addEventListener('updateready', function(e) {
      if (window.applicationCache.status == window.applicationCache.UPDATEREADY) {
        window.applicationCache.swapCache();
        window.location.reload();
      }
    }, false);
    // if (window.noupdate === false){
    //   window.onNoUpdate = init;
    // }else{
    //   init();
    // }
  });
})();
