task :prompt_company_action, [:company_id] => :prompt_company do |task, args|
  puts "You chose #{@company.name}"
  puts "Fetching tickets..."
  tickets = Freshdesk::Ticket.where(company_id: @company.id, per_page: 100, include: :requester)
  puts "#{tickets.count} #{'ticket'.pluralize(count: tickets.count)} to consider."

  cli = HighLine.new
  cli.choose do |menu|
    menu.prompt = "What next?"
    menu.choice "Show overview" do
      @tickets = tickets
      Rake::Task[:show_overview].invoke
    end

  end              
end