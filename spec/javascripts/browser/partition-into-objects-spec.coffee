describe 'partitionIntoObjects', ->
  stories = null

  beforeEach ->
    stories = []

    story = (summary, theme, worker, epoch) ->
      stories.push {
        summary
        theme
        worker
        epoch
      }
    story 'Write a test', 'tdd', 'ndp', 'past'
    story 'Watch it Fail', 'tdd', 'ndp', 'present'
    story 'Write the Code', 'tdd', 'ndpair', 'present'
    story 'Write a spec', 'bdd', 'ndpair', 'past'
    story 'Futz with the tools', 'bdd', 'ndpair', 'past'
    story 'Refactor', 'tdd', 'ndpair', 'future'

  describe 'no groupings', ->
    it 'returns data in values', ->
      expect(partitionIntoObjects(stories)).toEqual values: stories

  describe 'simple groupBy', ->
    result = null
    beforeEach ->
      result = partitionIntoObjects(stories, 'theme')
    it 'has groupBy', ->
      expect(result.groupBy).toEqual('theme')
    it 'has right number of groups', ->
      expect(result.values.length).toEqual(2)
    it 'has right group names', ->
      expect(result.values[0].group).toEqual('tdd')
      expect(result.values[1].group).toEqual('bdd')
    it 'last level has no groupBy property', ->
      _.each result.values, (v) ->
        expect(v.groupBy).toBeUndefined()
    it 'has right stories', ->
      expect(result.values[0].values).toEqual([stories[0], stories[1], stories[2], stories[5]])
      expect(result.values[1].values).toEqual([stories[3], stories[4]])

  describe 'two-level grouping', ->
    result = null
    beforeEach ->
      result = partitionIntoObjects(stories, 'theme', 'worker')
    it 'has groupBy label', ->
      expect(result.groupBy).toEqual('theme')
    it 'has right number of groups', ->
      expect(result.values.length).toEqual(2)
    it 'has right groupings', ->
      expect(result.values[0].group).toEqual('tdd')
      expect(result.values[1].group).toEqual('bdd')

    describe '1st level group', ->
      tddGroup = undefined
      beforeEach ->
        tddGroup = result.values[0]

      it 'has right labels', ->
        expect(tddGroup.group).toEqual('tdd')
        expect(tddGroup.groupBy).toEqual('worker')

      describe 'all second level groups', ->
        it 'exist', ->
          expect(tddGroup.values.length).toEqual(2)
        it 'have no groupBy property', ->
          _.each tddGroup.values, (g) ->
            expect(g.groupBy).toBeUndefined()
        it 'have values', ->
          _.each tddGroup.values, (g) ->
            expect(g.values.length).toBeGreaterThan 0
        it 'segments correctly', ->
          expect(tddGroup.values[0].group).toEqual('ndp')
          expect(tddGroup.values[1].group).toEqual('ndpair')

      describe 'a 2nd level group', ->
        tddNdpGroup = undefined
        beforeEach ->
          tddNdpGroup = tddGroup.values[0]
        it 'has group property', ->
          expect(tddNdpGroup.group).toEqual('ndp')
        it 'has values', ->
          expect(tddNdpGroup.values).toEqual([stories[0], stories[1]])
        it 'last level has no groupBy property', ->
          expect(tddNdpGroup.groupBy).toBeUndefined()


  describe 'given a sort Fn', ->
    sortFn = undefined
    it 'returns data in values', ->
      sortFn = jasmine.createSpy()
      expect(partitionIntoObjects(stories, sortFn)).toEqual values: stories

    it 'sorts first level', ->
      sortFn = (group, values) ->
        if group == 'theme'
          values.sort()

      result = partitionIntoObjects(stories, sortFn, 'theme')
      expect(result.groupBy).toEqual('theme')
      expect(result.values[0].group).toEqual('bdd')
      expect(result.values[1].group).toEqual('tdd')

    it 'sorts second level', ->
      sortFn = jasmine.createSpy()
      partitionIntoObjects(stories, sortFn, 'theme', 'worker')
      expect(sortFn).toHaveBeenCalledWith('theme', [ 'tdd', 'bdd' ])
      expect(sortFn).toHaveBeenCalledWith('worker', [ 'ndp', 'ndpair' ])
