require 'sinatra'

get '/' do
  @hosts = 'tpaw03'

  @date_range = Range.new(Date.today - 7,Date.today)

  @plugins_by_category = MuninGraph::Plugin.plugins.group_by { |plugin| plugin.graph_category }

  haml :index
end
