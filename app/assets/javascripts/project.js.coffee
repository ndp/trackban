app = angular.module("Trackban", ["ngResource"])

app.projectId = window.location.pathname.replace('/projects/','')

app.directive 'distribute', ($parse) ->
  {
    restrict: 'A',
    link: (scope, e, attrs) ->
      a = attrs['distribute']
      a = $parse(a)(scope)
      percent = 100.0/ a.length
      $(e).css 'width', "#{percent}%"
  }

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

  $scope.milestones = Milestone.query()

  $scope.milestone = (milestoneId) ->
    #    console.log 'find ', milestoneId, ' from ', $scope.milestones
    _.find $scope.milestones, (milestone) ->
      milestoneId == milestone._id

  $scope.milestoneName = (milestoneId) ->
    $scope.milestone(milestoneId)?.name or 'unresolved'

  $scope.partitions = ['milestone_id', 'epoch', 'theme']
  $scope.layoutKey = $scope.partitions.join('|')

  $scope.groupSortFn = (group, values) ->
#    console.log 'groupSortFn', group, values
    if (group == 'theme')
      values.sort()
    else if (group == 'epoch')
      values.sort (a,b) ->
        a1 = ['past','present','future','undefined'].indexOf(a)
        b1 = ['past','present','future','undefined'].indexOf(b)
        a1 > b1 ? -1 : 1

  $scope.stories = Story.query (stories)->
    #    console.log stories
    $scope.hier = partitionIntoObjects stories, $scope.groupSortFn, $scope.partitions...
#    console.log $scope.hier

#  $scope.projects = Project.query()

  $scope.addStory = ->
    story = Story.save($scope.newStory)
    $scope.stories.push(story)
    $scope.newStory = {}
]

#app.run = ($rootScope, $location, $anchorScroll, $routeParams) ->
#  $rootScope.$on '$routeChangeSuccess', (newRoute, oldRoute) ->
#    $location.hash($routeParams.scrollTo)
#    $anchorScroll()

