class Worker
  include Mongoid::Document
  field :name, type: String
  field :handle, type: String
  field :email, type: String
end
