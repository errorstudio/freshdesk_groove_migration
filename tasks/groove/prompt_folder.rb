namespace :groove do
  desc "Prompt for a folder to work with"
  task :prompt_folder do
    @cli = HighLine.new
    @cli.say "Loading folders..."
    folders = Groove::Folder.all
    @cli.choose do |menu|
      menu.prompt = "Which folder?"
      folders.each do |folder|
        menu.choice(folder.name) do
          @folder = folder
        end
      end
    end
  end
end