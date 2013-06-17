require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'pp'


class PivotalTrackerImporter

  def initialize(project_id)
    @project_id = project_id
  end

  attr_reader :project_id

  def import

    uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{project_id}")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.path, {'X-TrackerToken' => ENV['TOKEN']})
    end
    doc = Nokogiri::Slop(response.body)
    p = Project.new(states: %w{unscheduled unstarted in_progress delivered finished accepted},
                    past_states: %w{accepted},
                    present_states: %w{in_progress delivered finished},
                    future_states: %w{unstarted}) do |p|
      p.id = 'pivotal-tracker-' << doc.project.id.content
      p.name = doc.css('project').first.content
      p.valid_estimates = doc.project.point_scale.content.split(',')
      doc.project.memberships.membership.each do |m|
        w = Worker.new name: m.css("name").first.content,
                       handle: m.person.initials.content,
                       email: m.person.email.content
        p.workers << w
      end
    end
    p.save!

    uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{project_id}/stories")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.path, {'X-TrackerToken' => ENV['TOKEN']})
    end
    doc = Nokogiri::Slop(response.body)

    states = []
    doc.stories.story.each_with_index do |story, index|
      s = Story.new summary: story.css('name').first.content,
                    tags: [story.story_type.content],
                    project: p,
                    current_state: story.current_state.content
      s.id= "pivotal-tracker-story-#{story.css('id').first.content}"
      s.current_estimate = story.css('estimate').first.try(:content)
      s.created_at = story.css('created_at').first.content
      labels = story.css('labels').first.try(:content)
      s.tags.unshift *labels.split(',') unless labels.blank?
      s.theme = s.tags.size > 1 ? s.tags[0] : 'undefined'
      unless story.description.blank?
        s.actions << (Action.new note: story.description)
      end

      story.css('note').each do |note|
        #puts note.css('author').first.content
        s.actions << (Action.new note: note.css('text').first.content, author: note.css('author').first.content, created_at: note.css('noted_at').first.content)
      end

      states << s.current_state

      pp s.as_json(methods: :actions) if index < 7

      s.save!
    end


    #puts states.uniq.compact.sort
    #render :xml => response.body
    p
  end
end