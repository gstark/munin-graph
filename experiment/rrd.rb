require "rrd"

rrd = RRD::Base.new("experiment/host-cpu-user-d.rrd")

options = {:start => Time.now - 24.hours, :end => Time.now}


# Fetching data from rrd
data = rrd.fetch(:average, options)
puts data[0].inspect
data = data[1..-1].reject { |time,value| value.respond_to?(:nan?) && value.nan? }
data.each do |time,value|
  time = Time.at(time.to_i)
  puts "#{time}, #{value}"
end
