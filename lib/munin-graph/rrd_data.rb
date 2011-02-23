module MuninGraph
  class RRDData

    DEFAULT_MUNIN_RRD_PATH = "/var/lib/munin"

    def initialize(plugin, host, metric)
      @plugin, @host, @metric = plugin, host, metric
    end

    def path
      @rrd_path ||= File.join(DEFAULT_MUNIN_RRD_PATH, @host, "host-#{@plugin.name}-#{@metric}-g.rrd")
    end

    def data_points(date_range)
      data = rrd_data_for_date_range(date_range)

      data = data[1..-1] || []

      data.map { |data_point| [Time.at(data_point[0]), data_point[1]] }
    end

    private

    def rrd_data_for_date_range(range)
      data_range_options = { :start => range.begin, :end => range.end }

      rrd_data.fetch(:average, data_range_options)
    end

    def rrd_data
      @rrd_data ||= RRD::Base.new(rrd_path)
    end

  end
end
