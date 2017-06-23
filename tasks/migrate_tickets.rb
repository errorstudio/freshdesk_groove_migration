task migrate_tickets: :prompt_company_action do
  @agents = Freshdesk::Agent.all.to_a
  # this is where we migrate the tickets.

  # we have @tickets available, so we need to iterate over them to create new ones (unless they already exist - this needs to be idempotent.)

  # A thread in Freshdesk is made of one Freshdesk::Ticket and many Freshdesk::Conversation child objects.
  @cli.say "Migrating tickets for #{@company.name}"
  @cli.choose do |menu|
    menu.prompt = "What status should we migrate?"
    Freshdesk::Ticket::STATUSES.keys.collect(&:to_s).collect(&:titleize).each do |status|
      menu.choice status do
        migrate_tickets(status)
      end
    end
    menu.choice "All" do
      migrate_tickets('All')
    end
  end

end

def migrate_tickets(status)
  tickets = case status
              when 'All'
                @tickets
              else
                @tickets.select {|t| t.status == status}
            end
  tickets.each do |ticket|
    @cli.say "#{ticket.subject} (#{ticket.id})"
    migrate_ticket(ticket)
  end
end

def migrate_ticket(ticket)
  # check the ticket doesn't already exist.
  if ticket_exists_in_groove?(ticket)
    @cli.say "Ticket already exists"
    return
  else
    if create_ticket_in_groove(ticket)
      @cli.say "Migrated successfully."
    end

  end
end

def ticket_exists_in_groove?(ticket)
  cleanup = ->(content) do
    content.gsub(/[^A-z0-9 ]*/,"").truncate(100)
  end
  freshdesk_subject = cleanup.call(ticket.description_text)
  tickets = Groove::Ticket.all(per_page: 50, customer: ticket.requester[:email]).to_a rescue []

  matching_tickets = tickets.select do |ticket|
    summary = cleanup.call(ticket.summary)
    summary == freshdesk_subject
  end

  matching_tickets.any?
end

def create_ticket_in_groove(ticket)
  replies_and_notes = ticket.conversations.to_a
  @cli.say "#{replies_and_notes.count} replies and notes"

  state = case ticket.status
            when "Open",
              :opened
            when "Waiting on customer", "Pending", "Waiting on third party"
              :pending
            else
              :closed
          end

  params = {
    to: 'help@error.agency',
    from: {
      email: ticket.requester[:email],
      name: ticket.requester[:name],
      company: @company.name
    },
    tags: "Freshdesk Import",
    body: ticket.description,
    sent_at: ticket.created_at,
    state: state,
    send_copy_to_customer: false,
    subject: ticket.subject
  }

  groove_ticket = Groove::Ticket.create(params)

  create_thread_for_groove_ticket(groove_ticket, replies_and_notes)

end

def create_thread_for_groove_ticket(groove_ticket, replies_and_notes)
  # replies_and_notes are the freshdesk replies and notes to be created in groove

  replies_and_notes.each do |thread_item|
    create_thread_item_for_groove_ticket(groove_ticket, thread_item)
  end

end

def create_thread_item_for_groove_ticket(groove_ticket, thread_item)
  # is this a note or a message?
  params = {
    note: false,
    body: thread_item.body,
    send_copy_to_customer: false,
    sent_at: thread_item.created_at
  }
  if thread_item.incoming?
    # this is a customer message to us
    params[:author] = thread_item.from_email || groove_ticket.customer_email
  elsif thread_item.from_email.present? && !thread_item.private?
    # this is a message from us
    params[:author] = @agents.find {|a| a.id == thread_item.user_id}.try(:contact).try(:[],:email)
  elsif !thread_item.private?
    # this is a public note, which translates to a message
    params[:author] = @agents.find {|a| a.id == thread_item.user_id}.try(:contact).try(:[],:email)
  else
    # this is a private note
    params[:note] = true
    params[:author] = @agents.find {|a| a.id == thread_item.user_id}.try(:contact).try(:[],:email)
  end

  groove_ticket.messages.create(params)

  
end