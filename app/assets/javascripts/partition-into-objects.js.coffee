# Takes a list of objects, and groups them
# according the the groupings provided.
#
# Examples,
#   partitionIntoObjects(users) => { values: users }
#   partitionIntoObjects(users, 'state') =>
#      { groupBy: 'state',
#        values:
#         [ { group: 'CA',
#             values: [Object] },
#           { group: 'OR',
#             values: [Object] } ] }
#   partitionIntoObjects(users, 'country', 'state') =>
#      { groupBy: 'country',
#        values:
#         [ { group: 'US',
#             groupBy: 'state',
#             values: [
#               { group: 'CA', values: [Object, Object, Object] }
#               { group: 'OR', values: [Object] }
#             ] },
#           { group: 'MX', ...
#
window.partitionIntoObjects = (stories, sortFn, groupings...) ->
  groupings = [] if groupings == undefined
  if sortFn and !_.isFunction(sortFn)
    groupings.unshift(sortFn)
    sortFn = null

  if groupings.length == 0
    {
      values: stories
    }
  else
    groupBy = groupings.shift()
    groups = _.uniq(_.pluck stories, groupBy)
    sortFn(groupBy, groups) if sortFn
    # put together list of stories for each group
    values = _.map groups, (group) ->
      s = _.select stories, (story) -> story[groupBy] == group
      _.extend {group}, partitionIntoObjects(s, sortFn, groupings...)
    { groupBy: groupBy, values }

