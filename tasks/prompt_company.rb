task :prompt_company do
  @cli = HighLine.new
  @cli.say "Loading companies..."
  companies = Freshdesk::Company.all.to_a
  @cli.choose do |menu|
    menu.prompt = "Which client?"
    companies.each do |company|
      menu.choice(company.name) do
        @company = company
      end
    end
  end
end