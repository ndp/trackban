class Action
  include Mongoid::Document
  field :note, type: String
  field :assignee, type: String
  field :state, type: String
end
