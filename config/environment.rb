require 'her'
require 'require_all'
require 'logger'
require 'highline'
require 'byebug'
require 'terminal-table'
require 'yaml'

$credentials = YAML.load_file('config/credentials.yml').with_indifferent_access


load 'config/freshdesk.rb'
load 'config/groove.rb'

require_all 'models/**/*.rb'