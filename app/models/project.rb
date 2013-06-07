class Project
  include Mongoid::Document
  field :name, type: String
  has_many :stories
  embeds_many people
  embeds_many actions
end
