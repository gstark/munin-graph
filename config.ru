require 'bundler'

Bundler.setup
Bundler.require(:default)

require 'lib/munin-graph'
require 'munin_graph_server'

run Sinatra::Application
