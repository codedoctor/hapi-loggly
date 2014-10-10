_ = require 'underscore'
loggly = require 'loggly'

###
options:

  token
  subdomain
  tags
  auth (username, password)
  verbose: true/false 
  
###
module.exports.register = (plugin, options = {}, cb) ->

    # DO STUFF HERE
  logglyClient = null

  if options.token or (options.auth and options.auth.username and options.auth.password)
    logglyClient = loggly.createClient
        token: options.token
        subdomain: options.subdomain
        tags: options.tags || []
        json: true
        auth: options.auth
  else
    console.log "Remote logging to loggly.com DISABLED - missing LOGGLYTOKEN or LOGGLYUSERNAME, LOGGLYPASSWORD"

  registerLog = (eventEmitter,eventName = "log") ->
    eventEmitter.on eventName, (event = {}, tags = {}) ->

      # event type 1
      tagsArray = tags.tags
      if event._logger
        data = _.omit( ( _.last event._logger ), 'tags' )

      # event type 2
      if _.isUndefined data 
        data =
          data: event.data

      if _.isUndefined tagsArray
        tagsArray = _.keys( tags )
      
      # always make a ISO 8601 timestamp
      if _.isUndefined event.timestamp
        data.timestamp = new Date().toISOString()
      else
        data.timestamp = new Date(event.timestamp).toISOString()
      
      if logglyClient
        logglyClient.log data, tagsArray, (err) ->
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

