var cleanOpt, cli, fs, serve, _;
cli = require('cli');
fs = require('fs');
_ = require('underscore')._;
serve = require('./serve');
cli.parse({
  src: ['s', 'Source directory', 'path', './src'],
  verbose: ['v', 'Print more', 'boolean', false],
  silent: ['s', 'stop output', 'boolean', false],
  host: ['a', 'Address to serve on', 'string', '0.0.0.0'],
  port: ['p', 'Serve on port', 'number', 3000],
  autobuild: [false, 'Automatically rebuild on file change', 'boolean', false],
  noappcache: [false, 'Disable HTML5 Application Cache', 'boolean', false],
  jsconf: ['c', 'JSON config file', 'path', './localConf.json'],
  test: ['t', 'Build js with tests', 'boolean', false],
  minify: ['m', 'Minify JS using Uglify JS', 'boolean', false],
  pretify: ['p', 'Pretify minified JS using Uglify JS', 'boolean', false]
});
cleanOpt = function(opt, clbk) {
  return fs.realpath(opt.src, function(err, srcPath) {
    if (err != null) {
      cli.fatal(err);
    }
    opt.src = srcPath;
    return fs.readFile(opt.src + '/conf.json', 'utf8', function(err, data) {
      if (err != null) {
        cli.fatal(err);
      }
      return fs.readFile(opt.jsconf, 'utf8', function(err, localData) {
        if (err != null) {
          cli.fatal(err);
        }
        opt.conf = _.extend({}, JSON.parse(data), JSON.parse(localData));
        return clbk(opt);
      });
    });
  });
};
cli.main(function(args, opt) {
  if (opt.silent) {
    cli.status = function() {};
  }
  return cleanOpt(opt, function(opt) {
    return serve.run(opt);
  });
});