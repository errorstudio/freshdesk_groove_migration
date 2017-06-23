module Freshdesk
  class Conversation
    include Her::Model
    use_api FRESHDESK_API

    belongs_to :ticket

    after_find ->(record) {
      record.from_email = record.from_email.match(/<(.*)>/)[1] rescue nil
      record.created_at = DateTime.parse(record.created_at)
      record.updated_at = DateTime.parse(record.updated_at)
    }

  end
end