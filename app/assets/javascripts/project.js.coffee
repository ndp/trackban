app = angular.module("Trackban", ["ngResource"])

app.projectId = '51b55205cd13fc3b9c00033c'
app.projectId = 'pivotal-tracker-83'
app.projectId = window.location.pathname.replace('/projects/','')

app.factory "Story", ["$resource", ($resource) ->
  $resource("/projects/:project_id/stories/:id", {id: "@id", project_id: app.projectId}, {update: {method: "PUT"}})
] #epoch: unscheduled

app.factory "Project", ["$resource", ($resource) ->
  $resource("/projects/:id", {id: "@id"}, {update: {method: "PUT"}})
]


@TrackbanCtrl = ["$scope", 'Project', "Story", ($scope, Project, Story) ->
#  $scope.project = Project.get($scope.project_id)
  $scope.epochsHash = {}
  $scope.epochs = $.map ['past','present','future','undefined'], (name) ->
    $scope.epochsHash[name] = {name: name, stories: [], themes: []}


  $scope.addStoryToEpoch = (story) ->
#    console.log 'addStoryToEpoch', story
#    console.log 'scope.epochs', $scope.epochs
    e = $scope.epochsHash[story.epoch]
    e.stories.push(story)
    e.themes.push(story.theme) if e.themes.indexOf(story.theme) == -1


  $scope.stories = Story.query (stories)->
    angular.forEach stories, (story) -> $scope.addStoryToEpoch(story)

  $scope.projects = Project.query()

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

