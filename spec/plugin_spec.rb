require "lib/plugin"

describe Plugin do

  describe "#discover" do
    it "finds have as many plugins there are files in the plugin path" do
      Dir.should_receive(:entries).and_return([".", "..", "if_eth0", "if_eth1", "cpu"])

      Plugin.discover.should have(3).plugins
    end
  end
  
  describe "#parse_config" do
    before(:each) do
      @plugin = Plugin.new("/path/to/plugin")

      @plugin.should_receive(:raw_config).and_return(<<END
graph_order down up
graph_title eth0 traffic
graph_args --base 1000
graph_vlabel bits in (-) / out (+) per ${graph_period}
graph_category network
graph_info This graph shows the traffic of the eth0 network interface. Please note that the traffic is shown in bits per second, not bytes. IMPORTANT: Since the data source for this plugin use 32bit counters, this plugin is really unreliable and unsuitable for most 100Mb (or faster) interfaces, where bursts are expected to exceed 50Mbps. This means that this plugin is usuitable for most production environments. To avoid this problem, use the ip_ plugin instead.
down.label received
down.type COUNTER
down.graph no
down.cdef down,8,*
up.label bps
up.type COUNTER
up.negative down
up.cdef up,8,*
up.info Traffic of the eth0 interface. Maximum speed is 1000000000 bits per second.
up.max 1000000000
down.max 1000000000
END
)
      @plugin.parse_config
    end

    it "should take any parameter without a '.' as a plain parameter" do
      @plugin.parameters["graph_order"].should == "down up"
    end

    it "should take any parameter with a '.' as a parameter describing a metric" do
      @plugin.metrics.should include("down")
      @plugin.metrics.should include("up")

      @plugin.metrics["up"]["type"].should == "COUNTER"
    end
  end
end
