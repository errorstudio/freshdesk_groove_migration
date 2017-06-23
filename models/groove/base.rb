module Groove
  class Base
    include Her::Model
    use_api GROOVE_API

    after_find ->(record) {
      record.created_at = DateTime.parse(record.created_at) rescue nil
      record.updated_at = DateTime.parse(record.updated_at) rescue nil
    }
  end
end