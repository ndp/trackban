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


alarmService = ->
  '!'
sleepService = (n)->
  Array(n).join 'z'


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
    # Angular uses an injector, which has
    # access to all the services
    $inject = angularStyleInjector serviceLocator

    night = undefined
    # Define a new service for the nighttime
    # Dependencies are parameters to a function
    # that returns the actual service
    nightService = $inject (alarmService, sleepService) ->
      (i, awake) ->
        night = @sleepService(i) + @alarmService() + awake
        i

    # We can use our new service and it finds what it needs
    result = nightService(7, ' yum')
    expect(result).toEqual(7)
    expect(night).toEqual('zzzzzz! yum')


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
    nightService = $inject (i,wake) ->
      night = @sleepService(i) + @alarmService() + wake
      i

    # We can use our new service and it finds what it needs
    result = nightService(7, ' morning!')
    expect(result).toEqual(7)
    expect(night).toEqual('zzzzzz! morning!')

describe 'objectStyle', ->

  objectStyleInjector = (serviceLocator) ->
    (o) ->
      for p of o
        service = serviceLocator(p)
        o[p](service) if service
      o

  it 'injects', ->
    $inject = objectStyleInjector serviceLocator

    night = undefined

    # Define a new service for the nighttime
    # Dependencies referenced off of `this`
    nightService = $inject {
      sleepService: (s) -> @sleepService = s
      alarmService: (s) -> @alarmService = s
      go: (i,wake) ->
        night = @sleepService(i) + @alarmService() + wake
        i
    }

    # We can use our new service and it finds what it needs
    result = nightService.go(7, ' morning!')
    expect(result).toEqual(7)
    expect(night).toEqual('zzzzzz! morning!')

describe 'objectStyle 2', ->

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

    nightService = $inject {
      sleepService: $inject
      alarmService: $inject
      report: (i,wake) ->
        night = @sleepService(i) + @alarmService() + wake
        i
    }


    # We can use our new service and it finds what it needs
    result = nightService.report(7, ' morning!')
    expect(result).toEqual(7)
    expect(night).toEqual('zzzzzz! morning!')
