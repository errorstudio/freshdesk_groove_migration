task :prompt_company_action, [:company_id] => :prompt_company do |task, args|
  @cli.say "You chose #{@company.name}"
  @cli.say "Fetching tickets..."
  tickets = Freshdesk::Ticket.where(company_id: @company.id, per_page: 100, include: :requester)
  @cli.say "#{tickets.count} #{'ticket'.pluralize(count: tickets.count)} to consider."

  @cli.choose do |menu|
    menu.prompt = "What next?"
    menu.choice "Show overview" do
      @tickets = tickets
      Rake::Task[:show_overview].invoke
    end
    menu.choice "Migrate tickets" do
      @tickets = tickets
      Rake::Task[:migrate_tickets].invoke
    end

  end              
end