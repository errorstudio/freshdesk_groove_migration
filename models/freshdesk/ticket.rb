module Freshdesk
  class Ticket
    include Her::Model
    use_api FRESHDESK_API

    has_many :conversations

    STATUSES = {
      open: 2,
      pending: 3,
      resolved: 4,
      closed: 5,
      waiting_on_customer: 6
    }

    CLOSED = [
      STATUSES[:closed],
      STATUSES[:resolved]
    ]

    after_find ->(r) {
      r.status_id = r.status
      r.status = r.status_text
      r.created_at = DateTime.parse(r.created_at)
      r.updated_at = DateTime.parse(r.updated_at)
    }

    def url
      "http://help.error.agency/helpdesk/tickets/#{id}"
    end

    def status_text
      Ticket::STATUSES.invert[status].to_s.humanize
    end

    def company
      Freshdesk::Company.find(company_id)
    end

    def contact
      Freshdesk::Contact.find(requester_id)
    end

  end
end
