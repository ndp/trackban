class Story
  include Mongoid::Document
  include Mongoid::Timestamps
  field :summary, type: String
  field :current_state, type: String
  field :current_estimate, type: Integer
  field :current_worker, type: Moped::BSON::ObjectId
  field :position, type: Float
  field :tags, type: Array
  field :theme, type: String
  has_many :stories
  belongs_to :project
  belongs_to :story
  belongs_to :milestone
  embeds_many :actions

  def epoch
    project.map_state_to_epoch(current_state)
  end
end
