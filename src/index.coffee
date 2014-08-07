
###
options:

  token
  subdomain
  tags
  auth (username, password)
###
module.exports.register = (plugin, options = {}, cb) ->

    # DO STUFF HERE
  logglyClient = null

  if options.token and options.username and options.password
    logglyClient = loggly.createClient
        token: options.token
        subdomain: options.subdomain
        tags: options.tags || []
        json: true
        auth: options.auth
  else
    console.log "Remote logging to loggly.com DISABLED - missing LOGGLYTOKEN, LOGGLYUSERNAME, LOGGLYPASSWORD"

  registerLog = (eventEmitter,eventName = "log") ->
    eventEmitter.on eventName, (event = {}, tags = {}) ->
      data = event.data
      data = msg: data if _.isString data

      if logglyClient
        logglyClient.log data,_.keys(tags), (err) ->
          ###
          THIS SHOULD TRIGGER new relic
          ###
          console.log "Logging error #{err}" if err
      else
        console.log "INFO: #{JSON.stringify(data || "NODATA")}"

  for server in plugin.servers || []
    console.log "Logging for server: #{server.info.uri}" if options.verbose
    registerLog eventEmitter for eventEmitter in [server.pack.events,server]
    registerLog server, 'request'

  plugin.expose 'logglyClient', logglyClient

  cb()

module.exports.register.attributes =
  pkg: require '../package.json'

