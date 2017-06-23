task :show_overview => :prompt_company_action do |task, args|
  # we'll have @tickets from prompt_company_action and @company from :prompt_company
  table = Terminal::Table.new title: @company.name, headings: ['Status', 'Count']
  @tickets.group_by(&:status).each do |status, tickets|
    table.add_row [status, tickets.count]
  end

  @cli.say table

end
