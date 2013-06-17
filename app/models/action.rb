class Action
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  field :actor, type: Moped::BSON::ObjectId
  field :worker_assigned, type: Moped::BSON::ObjectId
  field :note, type: String
  field :state, type: String
  field :estimate, type: Moped::BSON::ObjectId
  embedded_in :story
end
