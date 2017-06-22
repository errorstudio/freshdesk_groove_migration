module Freshdesk
  class Contact
    include Her::Model
    use_api FRESHDESK_API
  end
end