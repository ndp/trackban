class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :valid_estimates, type: Array
  has_many :stories
  embeds_many :workers
  embeds_one :workflow
  field :past_states, type: Array
  field :present_states, type: Array
  field :future_states, type: Array

  def self.seed
    #Project.delete_all
    Project.create! name: 'Sample Project Again',
                    states: %w{unscheduled unstarted in_progress delivered finished accepted},
                    past_states: %w{accepted},
                    present_states: %w{in_progress delivered finished},
                    future_states: %w{unstarted},
                    valid_estimates: [0, 1, 2, 3, 5, 8, 13, 21, 34, 55]

  end

  def map_state_to_epoch(state)
    return 'future' if future_states.include? state
    return 'present' if present_states.include? state
    return 'past' if past_states.include? state
    return 'undefined'
  end

  def themes
    stories.map(&:theme).compact.uniq
  end
end
