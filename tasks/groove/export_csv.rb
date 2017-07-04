namespace :groove do
  desc "Export tickets for a particular folder in Groove"
  task csv: :"groove:prompt_folder" do
    filename = @cli.ask "CSV filename?"
    @cli.say "Getting tickets"
    tickets = Groove::Ticket.where(folder: @folder.id).to_a
    @cli.say "Generating CSV"
    csv = CSV.generate(force_quotes: true) do |csv|
      csv << [:group, :customer_email, :title, :summary, :messages]
      tickets.each do |ticket|
        csv << [
          ticket.assigned_group,
          ticket.customer_email,
          ticket.title,
          ticket.summary.squish.gsub(/[\u2018\u2019]/, '\''),
          #
          ticket.messages.collect(&:plain_text_body).collect {|b| b.squish.gsub(/[\u2018\u2019]/, '\'')}.join("\r\r")
        ]
      end
    end


    File.open(filename, "w") {|f| f.puts csv}
    @cli.say "Exported to #{filename}"
  end
end