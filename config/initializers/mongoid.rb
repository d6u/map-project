# add id field to Mongoid object when convert to JSON
module Mongoid
  module Document
    def as_json(options={})
      attrs = super(options)
      attrs["id"] = self.id.to_s
      attrs["created_at"] = self.c_at
      attrs["updated_at"] = self.u_at
      attrs.delete('c_at')
      attrs.delete('u_at')
      attrs
    end
  end
end
