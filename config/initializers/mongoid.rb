# add id field to Mongoid object when convert to JSON
module Mongoid
  module Document
    def as_json(options={})
      attrs = super(options)
      attrs["id"] = self.id.to_s
      attrs
    end
  end
end
