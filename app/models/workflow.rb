class Workflow
  include Mongoid::Document
  embedded_in :project
  field :states, type: Array
  field :past_states, type: Array
  field :present_states, type: Array
  field :future_states, type: Array
end
