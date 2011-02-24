
module MuninGraph
  class Plugin

    DEFAULT_MUNIN_PLUGIN_PATH = "/etc/munin/plugins"

    # Given a path to a directory, discovers all the available
    # plugins in the system
    def self.plugins(path = DEFAULT_MUNIN_PLUGIN_PATH)
      Dir.entries(path).map do |plugin_name|
        next if plugin_name == "." || plugin_name == ".."

        Plugin.new(File.join(path, plugin_name))
      end.compact
    end

    # Create a plugin from a definition given by the file at path
    def initialize(path)
      @path = path
      @config = { PARAMETER_KEY => {}, METRIC_KEY => {} }
      @config_loaded = false
    end

    def name
      @name ||= File.basename(@path)
    end

    def graph_category
      load_config_if_needed

      parameters["graph_category"]
    end

    # Returns a hash of parameter names and their values
    # 
    # Example:
    #   plugin.parameters # => { "graph_name" => "Super Graph", "graph_order" => "first second"}
    def parameters
      load_config_if_needed

      @config[PARAMETER_KEY]
    end

    # Returns a hash of metric names to a hash of parameters
    # 
    # Example:
    #   plugin.metrics # => { "first" => { "label" => "The first param" }, "second" => { "label" => "The second parameter " } }
    def metrics
      load_config_if_needed

      @config[PARAMETER_KEY]
    end

    def rrd_data(host, metric)
      RRDData.new(self, host, metric)
    end

    private

    # Parse the configuration data, call before access parameters or metrics
    # 
    # Note to RMU reviewers: Nominally I would call this from the initialize
    #   but I thus can't figure out how to handle the mocking of the #raw_config
    #   What can I do to avoid having this 'must call before' requirement but
    #   still handle the 'should_receive().and_return()' in specs?
    # 
    def parse_config
      raw_config.split("\n").each do |line|
        match = CONFIG_MATCH_EXPRESSION.match(line)

        next unless match

        key, value = match[1], match[2]

        if key.include?('.')
          metric_name, metric_parameter = key.split('.')

          metrics[metric_name] ||= {}
          metrics[metric_name][metric_parameter] = value
        else
          parameters[key] = value
        end
      end
    end

    def load_config_if_needed
      return if config_loaded?

      @config_loaded = true

      parse_config
    end

    def config_loaded?
      @config_loaded
    end

    def raw_config
      `#{@path} config`
    end

    PARAMETER_KEY = "parameters"

    METRIC_KEY = "metrics"

    CONFIG_MATCH_EXPRESSION = /(.+?) (.+)/
  end
end
