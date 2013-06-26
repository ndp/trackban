app = angular.module("Trackban", ["ngResource"])

app.projectId = '51b55205cd13fc3b9c00033c'
app.projectId = 'pivotal-tracker-83'
app.projectId = window.location.pathname.replace('/projects/','')


app.directive 'story', () ->
  {
    restrict: 'E',
    link: (scope, element) ->
    template: '<h4>{{story.summary}}</h4>'
  }

# adds a class on hover
app.directive 'hover', () ->
  (scope, e, attrs) ->
    e.bind 'mouseenter', ->
      e.addClass(attrs.hover)
    e.bind 'mouseleave', ->
      e.removeClass(attrs.hover)

app.factory "Story", ["$resource", ($resource) ->
  $resource("/api/projects/:project_id/stories/:id", {id: "@id", project_id: app.projectId}, {update: {method: "PUT"}})
] #epoch: unscheduled

app.factory "Project", ["$resource", ($resource) ->
  $resource("/api/projects/:id", {id: "@id"}, {update: {method: "PUT"}})
]

app.factory "Milestone", ["$resource", ($resource) ->
  $resource("/api/projects/:project_id/milestones/:id", {id: "@id", project_id: app.projectId}, {update: {method: "PUT"}})
]

@ProjectListCtrl = ["$scope", 'Project', ($scope, Project) ->
  $scope.projects = Project.query()
]

@TrackbanCtrl = ["$scope", 'Project', "Story", 'Milestone', ($scope, Project, Story, Milestone) ->
#  $scope.project = Project.get($scope.project_id)
  $scope.epochsHash = {}
  $scope.epochs = $.map ['past','present','future','undefined'], (name) ->
    $scope.epochsHash[name] = {name: name, stories: [], themes: [], milestones: {}}

  # epochsHash['past']['stories']
  # epochsHash['past']['themes']
  # epochsHash['past']['milestones']

  $scope.addStoryToEpoch = (story) ->
#    console.log 'addStoryToEpoch', story
#    console.log 'scope.epochs', $scope.epochs
    e = $scope.epochsHash[story.epoch]
    e.stories.push(story)
    e.themes.push(story.theme) if e.themes.indexOf(story.theme) == -1

    if !e.milestones[story.milestone_id]
      e.milestones[story.milestone_id] = { stories: [story], themes: [story.theme]}
    else
      e.milestones[story.milestone_id].stories.push(story)
      e.milestones[story.milestone_id].themes.push(story.theme) if e.milestones[story.milestone_id].themes.indexOf(story.theme) == -1

  $scope.milestones = Milestone.query()

  $scope.milestone = (milestoneId) ->
    console.log 'find ', milestoneId, ' from ', $scope.milestones
    _.find $scope.milestones, (milestone) ->
      milestoneId == milestone._id

  $scope.milestoneName = (milestoneId) ->
    $scope.milestone(milestoneId)?.name or 'unresolved'

  $scope.stories = Story.query (stories)->
    angular.forEach stories, (story) -> $scope.addStoryToEpoch(story)
    $scope.hier = partitionIntoObjects stories, 'epoch', 'milestone_id', 'theme'
    console.log $scope.hier

#  $scope.projects = Project.query()

  $scope.themes = (stories)->
    themes = []
    angular.forEach stories, (story) ->
      themes.push(story.theme) if themes.indexOf(story.theme) == -1
    themes

  $scope.addStory = ->
    story = Story.save($scope.newStory)
    $scope.stories.push(story)
    $scope.newStory = {}
]

#app.run = ($rootScope, $location, $anchorScroll, $routeParams) ->
#  $rootScope.$on '$routeChangeSuccess', (newRoute, oldRoute) ->
#    $location.hash($routeParams.scrollTo)
#    $anchorScroll()

