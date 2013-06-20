require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'pp'


class PivotalTrackerImporter

  def initialize(tracker_project_id)
    @tracker_project_id = tracker_project_id
  end

  attr_reader :tracker_project_id

  def import
    new_project = fetch_project

    fetch_stories(new_project)

    new_project
  end

  def fetch_project
    uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{tracker_project_id}")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.path, {'X-TrackerToken' => ENV['TOKEN']})
    end
    doc = Nokogiri::Slop(response.body)
    existing_project = Project.where(id: "pivotal-tracker-#{tracker_project_id}").first
    project = existing_project || Project.new(states: %w{unscheduled unstarted in_progress delivered finished accepted},
                                              past_states: %w{accepted},
                                              present_states: %w{in_progress delivered finished},
                                              future_states: %w{unstarted}) do |p|
      p.id = 'pivotal-tracker-' << doc.project.id.content
    end
    project.name = doc.project.css('name').first.content
    project.valid_estimates = doc.project.point_scale.content.split(',')
    project.workers = []
    doc.project.memberships.membership.each do |m|
      w = Worker.new name: m.css("name").first.content,
                     handle: m.person.initials.content,
                     email: m.person.email.content
      project.workers << w
    end

    project.save!
    pp first: project
    project.reload
    pp reloaded: project
    project
  end

  def fetch_stories(project)
    uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{tracker_project_id}/stories")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.path, {'X-TrackerToken' => ENV['TOKEN']})
    end
    doc = Nokogiri::Slop(response.body)


    doc.stories.story.each do |node|
      if node.story_type.content == 'release'
        milestone = Milestone.new name: node.css('name').first.content,
                                  project: project,
                                  current_state: node.current_state.content
        milestone.id = "pivotal-tracker-story-#{node.css('id').first.content}"
        milestone.save!
        project.milestones << milestone
      end
    end
    project.milestones << Milestone.create!(name: 'End of Project', project: project)

    milestone_index = 0
    doc.stories.story.each_with_index do |node, index|
      milestone_index += 1 and next if node.story_type.content == 'release'
      story = Story.new summary: node.css('name').first.content,
                        tags: [node.story_type.content],
                        project: project,
                        milestone: project.milestones[milestone_index],
                        current_state: node.current_state.content
      story.id = "pivotal-tracker-story-#{node.css('id').first.content}"
      story.current_estimate = node.css('estimate').first.try(:content)
      story.created_at = node.css('created_at').first.content
      labels = node.css('labels').first.try(:content)
      story.tags.unshift *labels.split(',') unless labels.blank?
      story.theme = story.tags.size > 1 ? story.tags[0] : 'undefined'
      story.actions = []
      unless node.description.blank?
        story.actions << (Action.new note: node.description)
      end

      node.css('note').each do |note|
        #puts note.css('author').first.content
        story.actions << (Action.new note: note.css('text').first.content, author: note.css('author').first.content, created_at: note.css('noted_at').first.content)
      end

      pp story.as_json(methods: :actions) if index < 3

      story.save!

      project.stories << story
    end

  end
end