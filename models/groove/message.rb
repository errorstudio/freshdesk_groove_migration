module Groove
  class Message < Base
    belongs_to :ticket
    collection_path "tickets/:ticket_id/messages"
  end
end