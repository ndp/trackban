class Milestone
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  has_many :stories
  belongs_to :project
  # field :deadline, type:  Date
end