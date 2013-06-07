app = angular.module("Trackban", ["ngResource"])

app.factory "Story", ["$resource", ($resource) ->
  $resource("/projects/1/stories/:id", {id: "@id"}, {update: {method: "PUT"}})
]

@TrackbanCtrl = ["$scope", "Story", ($scope, Story) ->
  $scope.stories = Story.query()

  $scope.addStory = ->
    story = Story.save($scope.newStory)
    $scope.stories.push(story)
    $scope.newStory = {}

  $scope.drawWinner = ->

]
