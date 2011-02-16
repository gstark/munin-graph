class Plugin

  # Given a path to a directory, discovers all the available
  # plugins in the system
  def self.discover(plugin_path = "/etc/munin/plugins")
    Dir.entries(plugin_path).map do |plugin_name|
      next if plugin_name == "." || plugin_name == ".."

      Plugin.new(File.join(plugin_path, plugin_name))
    end.compact
  end

  # Create a plugin from a definition given by the file at plugin_path
  def initialize(plugin_path)
    @plugin_path = plugin_path
    @config = { PARAMETER_KEY => {}, METRIC_KEY => {} }
  end

  # Returns a hash of parameter names and their values
  # 
  # Example:
  #   plugin.parameters # => { "graph_name" => "Super Graph", "graph_order" => "first second"}
  def parameters
    @config[PARAMETER_KEY]
  end

  # Returns a hash of metric names to a hash of parameters
  # 
  # Example:
  #   plugin.metrics # => { "first" => { "label" => "The first param" }, "second" => { "label" => "The second parameter " } }
  def metrics
    @config[PARAMETER_KEY]
  end

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

  private

  def raw_config
  end

  PARAMETER_KEY = "parameters"
  
  METRIC_KEY = "metrics"

  CONFIG_MATCH_EXPRESSION = /(.+?) (.+)/
end
