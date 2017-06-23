module Groove
  class Ticket < Base
    primary_key :number
    has_many :messages

    after_find ->(record) {
      record.customer_email = record.links[:customer][:href].split("/").last
    }

    after_save ->(record) {
      record.customer_email = record.links[:customer][:href].split("/").last
    }
  end
end