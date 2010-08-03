#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'rest_client'

require "rexml/document"
require 'nokogiri'

require 'bagit'
require 'builder'
require 'cgi'
require 'rdf'

require 'active_support'

require 'ruote'
require 'ruote/storage/fs_storage'

def render_object_dc bag, obj
  open(obj + "/DC").read.gsub('<?xml version="1.0"?>', '')
end
 
$engine = Ruote::Engine.new(Ruote::Worker.new(Ruote::FsStorage.new('work')))

require 'workflows/participants/misc'
require 'workflows/participants/bagit'
require 'workflows/participants/metadata'
require 'workflows/participants/wgbh'
require 'workflows/participants/fedora'

require 'workflows/definitions/dam_to_bagit'
require 'workflows/definitions/bagit_to_fedora'

