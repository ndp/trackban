# Copyright (c) 2013 Andrew J. Peterson, NDP Software
fnTextWithoutComments = (fn) ->
  STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg
  fn.toString().replace(STRIP_COMMENTS, '')

# Lifted from angular $inject
argumentNames = (fn) ->

  fnText = fnTextWithoutComments(fn)

  FN_ARGS = /^function\s*[^\(]*\(\s*([^\)]*)\)/m
  argDecl = fnText.match(FN_ARGS);

  FN_ARG_SPLIT = /,/
  FN_ARG = /^\s*(_?)(\S+?)\1\s*$/

  args = [];
  _.each argDecl[1].split(FN_ARG_SPLIT), (arg) ->
    arg.replace FN_ARG, (all, underscore, name) ->
      args.push name
  args

describe 'argumentNames', ->
  it 'handles none', ->
    expect(argumentNames () -> {}).toEqual([])
  it 'handles one', ->
    expect(argumentNames (foo) -> {}).toEqual(['foo'])
  it 'handles N', ->
    expect(argumentNames (foo, bar) -> {}).toEqual(['foo','bar'])

members = (fn) ->
  fnText = fnTextWithoutComments(fn)
  thiss = fnText.match(/this\.(\w+)/g);

  vars = []
  _.each thiss, (ref) -> vars.push ref.split('.')[1]
  _.uniq vars

describe 'members', ->
  it 'handles none', ->
    expect(members () -> {}).toEqual([])
  it 'handles one', ->
    expect(members () -> { @foo }).toEqual(['foo'])
  it 'handles N', ->
    expect(members () -> {@foo, @bar}).toEqual(['foo','bar'])
  it 'handles dups', ->
    expect(members () -> {@foo, @bar, @foo}).toEqual(['foo','bar'])


sleepService = (n)->
  Array(n).join 'z'

alarmService = ->
  'beep'

serviceLocator = (name) ->
  # Note, this could also be a factory provider or
  # some other logic
  services = {alarmService, sleepService}
  services[name]


describe 'angularStyle', ->

  # See http://www.yusufaytas.com/dependency-injection-in-javascript/
  angularStyleInjector = (serviceLocator) ->
    (fn) ->
      # fetch the names of the arguments
      serviceNames = argumentNames(fn)
      # look up their services
      services = _.map serviceNames, (name) ->
        serviceLocator(name)
      # call original function with those services
      fn.call(@, services...)

  it 'injects', ->
    # Define a new service for the nighttime
    # Dependencies are parameters to a function
    # that returns the actual service
    night = undefined
    nightService = (alarmService, sleepService) ->
      (i, awake) ->
        night = "#{sleepService(i)} #{alarmService()} #{awake}"
        i

    # Angular uses an injector, which has
    # access to all the services
    $inject = angularStyleInjector serviceLocator

    # We can use our new service and it finds what it needs
    result = ($inject nightService)(7, 'stretch')
    expect(result).toEqual(7)
    expect(night).toEqual('zzzzzz beep stretch')


describe 'contextStyle', ->

  contextStyleInjector = (serviceLocator) ->
    (fn) ->
      serviceNames = members(fn)
      ->
        context = {}
        context[name] = serviceLocator(name) for name in serviceNames
        fn.apply context, arguments

  it 'injects', ->
    $inject = contextStyleInjector serviceLocator

    night = undefined

    # Define a new service for the nighttime
    # Dependencies referenced off of `this`
    nightService = (i,wake) ->
      night = "#{@sleepService(i)} #{@alarmService()} #{wake}"
      i

    # We can use our new service and it finds what it needs
    result = ($inject nightService)(7, 'morning!')
    expect(result).toEqual(7)
    expect(night).toEqual('zzzzzz beep morning!')

describe 'context piggyBack Style', ->

  contextStyleInjector = (serviceLocator) ->
    (o) ->
      fns = []
      for name of o
        fns.push o[name] if _.isFunction(o[name])
      for fn in fns
        serviceNames = members(fn)
        for name in serviceNames
          unless o[name]
            service = serviceLocator(name)
            o[name] = service if service
      o


  it 'injects', ->
    night = undefined

    # Member functions can be injected
    o =
      nightService: (i) ->
        night = "#{@sleepService(i)} #{@alarmService()} #{@wake}"
        i
      wake: 'hello'


    # We can use our new service and it finds what it needs
    $inject = contextStyleInjector serviceLocator
    $inject o
    result = o.nightService(7)
    expect(result).toEqual(7)
    expect(night).toEqual('zzzzzz beep hello')

describe 'objectStyle 2', ->

  objectStyleInjector = (serviceLocator) ->
    (o) ->
      for p of o
        service = serviceLocator(p)
        o[p](service) if service
      o

  it 'injects', ->

    night = undefined

    # Define a new service for the nighttime
    # Dependencies referenced off of `this`
    nightService = {
      sleepService: (s) -> @sleepService = s
      alarmService: (s) -> @alarmService = s
      go: (i,wake) ->
        night = "#{@sleepService(i)} #{@alarmService()} #{wake}"
        i
    }

    # We can use our new service and it finds what it needs
    $inject = objectStyleInjector serviceLocator
    result = ($inject nightService).go(7, 'morning!')
    expect(result).toEqual(7)
    expect(night).toEqual('zzzzzz beep morning!')

describe 'objectStyle 3', ->

objectStyleInjector = (serviceLocator) ->
  injector = (o) ->
    for p of o
      if o[p] == injector
        service = serviceLocator(p)
        o[p] = service
    o

  $inject = objectStyleInjector serviceLocator


  it 'injects', ->
    night = undefined

    nightService = {
      sleepService: $inject
      alarmService: $inject
      report: (i,wake) ->
        night = "#{@sleepService(i)} #{@alarmService()} #{wake}"
        i
    }


    # We can use our new service and it finds what it needs
    result = ($inject nightService).report(7, 'morning!')
    expect(result).toEqual(7)
    expect(night).toEqual('zzzzzz beep morning!')
