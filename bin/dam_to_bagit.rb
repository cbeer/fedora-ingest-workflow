#!/usr/bin/env ruby

$: << File.expand_path( File.dirname(__FILE__) + "./../lib")
require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: dam_to_bagit.rb [options] DAMXML bagroot"
  
  options[:asset_path] = '.'  
  opts.on('-p', '--path DIRECTORY', 'Asset base path') do |p|
    options[:asset_path] = p
  end
  
  options[:pid_ns] = 'org.wgbh.mla'
  opts.on('-n', '--pidns NS', 'Default PID prefix') do |p|
    options[:pid_ns] = p
  end
  
  options[:bag] = './bag'
  opts.on('-b', '--bag NS', 'Bag path') do |p|
    options[:bag] = p
  end
  
end

optparse.parse!



require 'fedora-ingest-workflow'

ASSET_BASE_PATH = options[:asset_path]

DEFAULT_PID_NS = options[:pid_ns]


if File.file? ARGV[0]
  pdef = WGBH::Workflow.dam_to_bagit
  wfid = $engine.launch(pdef, 'document' => open(ARGV[0]).read(), 'bag_root' => options[:bag])
  $engine.wait_for(wfid)
end