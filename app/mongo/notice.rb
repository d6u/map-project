class Notice
  include Mongoid::Document
  include Mongoid::Timestamps::Short

  field :type       , type: String
  field :sender     , type: Hash
  field :receiver_id, type: Integer
  field :body       , type: Hash
end
