app = angular.module("Trackban", ["ngResource"])

app.projectId = '51b55205cd13fc3b9c00033c'
app.projectId = 'pivotal-tracker-83'
app.projectId = window.location.pathname.replace('/projects/','')

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

  $scope.stories = Story.query (stories)->
    angular.forEach stories, (story) -> $scope.addStoryToEpoch(story)

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

