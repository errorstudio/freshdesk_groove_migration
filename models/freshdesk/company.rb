module Freshdesk
  class Company
    include Her::Model
    use_api FRESHDESK_API

    def tickets
      Ticket.where(company_id: id, per_page: 100)
    end
  end
end
