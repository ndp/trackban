class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :valid_estimates, type: Array
  has_many :stories, dependent: :destroy
  has_many :milestones, dependent: :destroy
  embeds_many :workers

  embeds_one :workflow
  field :past_states, type: Array
  field :present_states, type: Array
  field :future_states, type: Array


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
