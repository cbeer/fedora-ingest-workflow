#!/usr/bin/env ruby

$: << File.expand_path( File.dirname(__FILE__) + "./../lib")
require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: bagit_to_fedora.rb [options] bagroot"
   
  options[:pid_ns] = 'org.wgbh.mla'
  opts.on('-n', '--pidns NS', 'Default PID prefix') do |p|
    options[:pid_ns] = p
  end
  
  options[:host] = 'http://localhost:8180/fedora'
  opts.on('-h', '--host URL', 'Fedora Host') do |p|
    options[:host] = p
  end   
  
  options[:user] = 'fedoraAdmin'
  opts.on('-u', '--user Username', 'Fedora User') do |p|
    options[:user] = p
  end   
  
  options[:password] = ''
  opts.on('-p', '--password Password', 'Fedora Password') do |p|
    options[:password] = p
  end   
  
end

optparse.parse!

require 'fedora-ingest-workflow'

$: << File.expand_path( File.dirname(__FILE__) + "./../lib/fedora" )

require 'Fedora-API-M-WSDLDriver.rb'

# fedora connection
host = options[:host] + '/services/management'
$fedora_rest_uri = options[:host]
$fedora_user = options[:user]
$fedora_pass = options[:password]
$fedora = FedoraAPIM.new(host)
#$fedora.wiredump_dev = STDERR
$fedora.options['protocol.http.basic_auth'] << [options[:host], $fedora_user, $fedora_pass]

DEFAULT_PID_NS = options[:pid_ns]

if !Dir[ARGV[0]].nil?
  pdef = WGBH::Workflow.bagit_to_fedora
  wfid = $engine.launch(pdef, 'bag_root' => ARGV[0])
  $engine.wait_for(wfid)
end
