module Freshdesk
  class Agent
    include Her::Model
    use_api FRESHDESK_API
  end
end