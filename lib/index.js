
/*
options:

  token
  subdomain
  tags
  auth (username, password)
 */

(function() {
  module.exports.register = function(plugin, options, cb) {
    var eventEmitter, logglyClient, registerLog, server, _i, _j, _len, _len1, _ref, _ref1;
    if (options == null) {
      options = {};
    }
    logglyClient = null;
    if (options.token && options.username && options.password) {
      logglyClient = loggly.createClient({
        token: options.token,
        subdomain: options.subdomain,
        tags: options.tags || [],
        json: true,
        auth: options.auth
      });
    } else {
      console.log("Remote logging to loggly.com DISABLED - missing LOGGLYTOKEN, LOGGLYUSERNAME, LOGGLYPASSWORD");
    }
    registerLog = function(eventEmitter, eventName) {
      if (eventName == null) {
        eventName = "log";
      }
      return eventEmitter.on(eventName, function(event, tags) {
        var data;
        if (event == null) {
          event = {};
        }
        if (tags == null) {
          tags = {};
        }
        data = event.data;
        if (_.isString(data)) {
          data = {
            msg: data
          };
        }
        if (logglyClient) {
          return logglyClient.log(data, _.keys(tags), function(err) {

            /*
            THIS SHOULD TRIGGER new relic
             */
            if (err) {
              return console.log("Logging error " + err);
            }
          });
        } else {
          return console.log("INFO: " + (JSON.stringify(data || "NODATA")));
        }
      });
    };
    _ref = plugin.servers || [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      server = _ref[_i];
      if (options.verbose) {
        console.log("Logging for server: " + server.info.uri);
      }
      _ref1 = [server.pack.events, server];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        eventEmitter = _ref1[_j];
        registerLog(eventEmitter);
      }
      registerLog(server, 'request');
    }
    plugin.expose('logglyClient', logglyClient);
    return cb();
  };

  module.exports.register.attributes = {
    pkg: require('../package.json')
  };

}).call(this);

//# sourceMappingURL=index.js.map
