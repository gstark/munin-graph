require "lib/munin-graph"

module MuninGraph
  describe RRDData do
    let(:plugin)   { Plugin.new("/path/to/plugin")}
    let(:rrd_data) { RRDData.new(plugin, "host","metric") }
  
    describe "#path" do
      it "should return a file path based on a host and a metric" do
        rrd_data.path.should == File.join(RRDData::DEFAULT_MUNIN_RRD_PATH, "host", "host-#{plugin.name}-metric-g.rrd")
      end
    end

    describe "#data_points" do
      let(:date_range) { Range.new(Time.now - 50, Time.now) }

      it "drops the first result from the RRD data" do
        rrd_data.should_receive("rrd_data_for_date_range").and_return([["time",42], [0, 45.2]])

        rrd_data.data_points(date_range).should_not == [["time", 42]]
      end

      it "returns no data if the RRD data returns one item or less" do
        rrd_data.should_receive("rrd_data_for_date_range").with(date_range).and_return([])

        rrd_data.data_points(date_range).should be_empty
      end

      it "maps the first column of each row to a Time object" do
        time_as_string     = "Mon Feb 21 20:40:51 -0500 2011"
        time_as_from_epoch = 1298338851
        time_as_object     = Time.parse(time_as_string)

        rrd_data.should_receive("rrd_data_for_date_range").and_return([["time",42], [time_as_from_epoch, 45.2]])

        rrd_data.data_points(date_range).should == [[time_as_object,45.2]]
      end

      it "accepts a time range to return data for" do
        rrd_data.should_receive("rrd_data_for_date_range").with(date_range).and_return([])

        rrd_data.data_points(date_range)
      end

    end
  end
end
