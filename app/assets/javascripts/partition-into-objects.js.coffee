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
partitionIntoObjects = (stories, groupings...) ->
  groupings = [] if groupings == undefined
  if groupings.length == 0
    {
      values: stories
    }
  else
    groupBy = groupings.shift()
    groups = _.uniq(_.pluck stories, groupBy)
    # put together list of stories for each group
    values = _.map groups, (group) ->
      s = _.select stories, (story) -> story[groupBy] == group
      _.extend {group}, partitionIntoObjects(s, groupings...)
    { groupBy: groupBy, values }
