def render_object_dc path
  open(path + "/DC").read.gsub('<?xml version="1.0"?>', '')
end

def build_lazy_fedora_sip pid, path
 x = Builder::XmlMarkup.new
  x.instruct!

  x.digitalObject 'xmlns' => 'info:fedora/fedora-system:def/foxml#', 'VERSION' => '1.1', 'PID' => pid do
    x.objectProperties do
      x.property 'NAME' => 'info:fedora/fedora-system:def/model#state',
        'VALUE' => 'A'
    end

    x.datastream 'ID' => 'DC', 'STATE' => 'A', 'CONTROL_GROUP' => 'X' do
      x.datastreamVersion 'ID' => 'DC.0', 'MIMETYPE' => 'text/xml' do
        x.xmlContent do |n|
            n << render_object_dc(path)
        end
      end
    end
  end

x
end

$engine.register_participant 'fedora_ingest_collection_object' do |workitem|
  bag = BagIt::Bag.new workitem.fields['bag_root']
  
  # gather metadata
  bagit_metadata = open(bag.bag_dir + "/bag-info.txt") do |io|
    entries = io.read.split /\n(?=[^\s])/
    entries.inject({}) do |hash, line|
      name, value = line.chomp.split /\s*:\s*/i, 2
      hash.merge({name => value})
    end
  end

  # build SIP
  x = Builder::XmlMarkup.new
  x.instruct!

  x.digitalObject 'xmlns' => 'info:fedora/fedora-system:def/foxml#', 'VERSION' => '1.1', 'PID' => bagit_metadata["Internal-Sender-Identifier"].gsub('info:fedora/', '') do
    x.objectProperties do
    x.property 'NAME' => 'info:fedora/fedora-system:def/model#state',
      'VALUE' => 'A'
  end

  x.datastream 'ID' => 'DC', 'STATE' => 'A', 'CONTROL_GROUP' => 'X' do
    x.datastreamVersion 'ID' => 'DC.0', 'MIMETYPE' => 'text/xml' do
      x.xmlContent do
        x.tag! 'oai_dc:dc',
          'xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
          'xmlns:dc' => 'http://purl.org/dc/elements/1.1/' do

            x.tag! 'dc:identifier', bagit_metadata["Internal-Sender-Identifier"].gsub('info:fedora/', '')
            x.tag! 'dc:title', bagit_metadata["External-Identifier"]
            x.tag! 'dc:description', bagit_metadata["External-Description"]
            x.tag! 'dc:publisher', bagit_metadata["Contact-Name"] + " " + bagit_metadata["Source-Organization"]
          end
        end   
      end
    end
  end

  # submit the SIP
  $fedora.ingest(:objectXML => SOAP::SOAPBase64.new(x.target!), :format => 'info:fedora/fedora-system:FOXML-1.1', :logMessage => 'add collection metadata')
  $fedora.addRelationship(:pid => bagit_metadata["Internal-Sender-Identifier"].gsub('info:fedora/', ''), :relationship => 'info:fedora/fedora-system:def/model#hasModel', :object => 'info:fedora/wgbh:COLLECTION', :isLiteral => false, :datatype => nil) 
  
  # return the new PID
  bagit_metadata["Internal-Sender-Identifier"]
end


$engine.register_participant 'mint_identifier' do |workitem|

  bag = BagIt::Bag.new workitem.fields['bag_root']
  
  # gather metadata
  bagit_metadata = open(bag.bag_dir + "/bag-info.txt") do |io|
    entries = io.read.split /\n(?=[^\s])/
    entries.inject({}) do |hash, line|
      name, value = line.chomp.split /\s*:\s*/i, 2
      hash.merge({name => value})
    end
  end
  
  xml = Nokogiri::XML(workitem.fields['__bag_DC'])

  publisher =  xml.xpath('//dc:publisher', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first
  
  pidns = nil
  pidns ||= publisher.text.to_s.parameterize.to_s unless publisher.nil? or !(publisher.text =~ /WGBH/).nil?
  pidns ||= bagit_metadata["Bag-Group-Identifier"] unless bagit_metadata["Bag-Group-Identifier"].nil?
  pidns ||= DEFAULT_PID_NS

  pidid = workitem.fields['obj']
  pidid = xml.xpath('//dc:identifier', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.text.to_s.parameterize.to_s unless xml.xpath('//dc:identifier', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.nil?
  pidid = xml.xpath('//dc:source', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.text.to_s.gsub('.mov', '').gsub('CBS', '').parameterize.to_s if pidns == 'cbs-news'
  pidid = xml.xpath('//dc:source', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.text.to_s.gsub('.mov', '').gsub('ABC', '').parameterize.to_s if pidns == 'abc-news-videosource'
  pidid = xml.xpath('//dc:source', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.text.to_s.gsub('.mov', '').gsub(Regexp.new(pidns, true),'').parameterize.to_s if pidns == 'nara' || pidns == 'nafb'
  
  workitem.fields['identifier'] = pidns + ":" + pidid.gsub('_', '-').gsub(/^-/, '')
end

$engine.register_participant 'prepare_object' do |workitem|
  xml = Nokogiri::XML(workitem.fields['__bag_DC'])
  return false unless xml.xpath('//dc:rights', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.nil? || !(xml.xpath('//dc:rights', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.text =~ /Not to be released/ && !xml.xpath('//dc:rights', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.text =~ /Media not to be released/)
  true
end

$engine.register_participant 'fedora_ingest_object' do |workitem|
  pid = workitem.fields['identifier']
  
  graph = RDF::Graph.new
  RDF::NTriples::Reader.open(workitem.fields['bag_root'] + '/rdf.nt') do |reader|
    reader.each_statement do |s|
      graph << s if s.to_s =~ Regexp.new(workitem.fields['obj'])
    end
  end
  
  dc = Nokogiri::XML(workitem.fields['__bag_DC'])
  return false unless graph.query([RDF::URI.new(workitem.fields['obj']), RDF::URI.new('info:fedora/fedora-system:def/relations-external#isPartOf'), nil]).empty? and graph.query([RDF::URI.new(workitem.fields['obj']), RDF::URI.new('info:fedora/fedora-system:def/relations-external#isThumbnailOf'), nil]).empty? and graph.query([nil, RDF::URI.new('info:fedora/fedora-system:def/relations-external#hasThumbnail'), RDF::URI.new(workitem.fields['obj'])]).empty?
 
 
  sip = build_lazy_fedora_sip pid, workitem.fields['object_path']
  
  begin
    $fedora.purgeObject(:pid => pid, :logMessage => '!!', :force => false)
    sleep 1
  rescue
  end
  
  $fedora.ingest(:objectXML => SOAP::SOAPBase64.new(sip.target!), :format => 'info:fedora/fedora-system:FOXML-1.1', :logMessage => 'add object metadata')
  
  client = RestClient::Resource.new $fedora_rest_uri + "/objects/" + pid + "/datastreams/DC?controlGroup=X&dsLabel=DC%20Metadata&checksumType=DISABLED", :user => $fedora_user, :password => $fedora_pass
  
  client.post File.read(workitem.fields['object_path'] + "/DC"), :content_type => 'text/xml'
  
  client = RestClient::Resource.new $fedora_rest_uri + "/objects/" + pid + "/datastreams/PBCore?controlGroup=M&dsLabel=PBCore%20Metadata&checksumType=DISABLED", :user => $fedora_user, :password => $fedora_pass
  client.post File.read(workitem.fields['object_path'] + "/PBCore"), :content_type => 'text/xml'
  
  
  $fedora.addRelationship(:pid => pid, :relationship => 'info:fedora/fedora-system:def/model#hasModel', :object => 'info:fedora/wgbh:CONCEPT', :isLiteral => false, :datatype => nil)
  
#  $fedora.addRelationship(:pid => pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => workitem.fields["Internal-Sender-Identifier"], :isLiteral => false, :datatype => nil)
  
end


$engine.register_participant 'fedora_ingest_media_object' do |workitem| 
  dc = Nokogiri::XML(workitem.fields['__bag_DC'])
    
  rights = dc.xpath('//dc:rights', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first
  return false if rights.to_s =~ /Media is not to be released to Open Vault/
  
  pid = workitem.fields['identifier'].gsub(/.*?:/, 'asset:')
  
  
  begin
    $fedora.purgeObject(:pid => pid, :logMessage => '!!', :force => false)
    sleep 1
  rescue
  end
  
  damxml = Nokogiri::XML(workitem.fields['__bag_DAMXML'])
  
  sip = build_lazy_fedora_sip pid, workitem.fields['object_path']
  $fedora.ingest(:objectXML => SOAP::SOAPBase64.new(sip.target!), :format => 'info:fedora/fedora-system:FOXML-1.1', :logMessage => 'add object')
   
  $fedora.addRelationship(:pid => pid, :relationship => 'info:fedora/fedora-system:def/relations-external#isPartOf', :object => 'info:fedora/' + workitem.fields["identifier"], :isLiteral => false, :datatype => nil)
  
  client = RestClient::Resource.new $fedora_rest_uri + "/objects/" + pid + "/datastreams/DC?controlGroup=X&dsLabel=DC%20Metadata&checksumType=DISABLED", :user => $fedora_user, :password => $fedora_pass
  client.post File.read(workitem.fields['object_path'] + "/DC"), :content_type => 'text/xml'
  
  url = "http://openvault.wgbh.org/media/rights/level_0.xml"
  client = RestClient::Resource.new $fedora_rest_uri + "/objects/" + pid + "/datastreams/Rights?controlGroup=R&dsLabel=Rights&checksumType=DISABLED&dsLocation=" + CGI::escape(url) + "&mimeType=" + CGI::escape('text/xml'), :user => $fedora_user, :password => $fedora_pass
  client.post nil
  
  type = nil
  type = damxml.xpath('//WGBH_TYPE/@MEDIA_TYPE').first.to_s unless damxml.xpath('//WGBH_TYPE/@MEDIA_TYPE').first.nil?  
  type ||= dc.xpath('//dc:type', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.text unless dc.xpath('//dc:type', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.nil?
  type ||= 'Transcript' if dc.xpath('//dc:source', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.text =~ /xml$/
  type ||= 'Still' if dc.xpath('//dc:source', { 'dc' => 'http://purl.org/dc/elements/1.1/' }).first.text =~ /png$/
  type ||= 'Other'
  
  datastreams = Dir.glob(workitem.fields['object_path'] + '/*')
  case type
    when /Moving Image/
      # Proxy
#      client = RestClient::Resource.new $fedora_rest_uri + "/objects/" + pid + "/datastreams/Proxy?controlGroup=M&dsLabel=Proxy&checksumType=DISABLED", :user => $fedora_user, :password => $fedora_pass
#      client.post File.read(workitem.fields['object_path'] + '/File'), :content_type => 'video/quicktime'
      
      url = "http://openvault.wgbh.org:8080/videos/" + File.basename(File.readlink(workitem.fields['object_path'] + '/File'))
      
      client = RestClient::Resource.new $fedora_rest_uri + "/objects/" + pid + "/datastreams/Proxy?controlGroup=R&dsLabel=Proxy&checksumType=DISABLED&dsLocation=" + CGI::escape(url) + "&mimeType=" + CGI::escape('video/quicktime'), :user => $fedora_user, :password => $fedora_pass
      client.post nil
      
      $fedora.addRelationship(:pid => pid, :relationship => 'info:fedora/fedora-system:def/model#hasModel', :object => 'info:fedora/wgbh:VIDEO', :isLiteral => false, :datatype => nil)
      
  end
  # media
  # thumbnails
  datastreams.select { |x| File.basename(x) =~ /^__tn_/ }.each do |tn|
    client = RestClient::Resource.new $fedora_rest_uri + "/objects/" + pid + "/datastreams/" + File.basename(tn) + '?controlGroup=M&dsLabel=' + File.basename(tn) + '&checksumType=DISABLED', :user => $fedora_user, :password => $fedora_pass
    client.post File.read(tn), :content_type => 'image/jpg'
  end

end

$engine.register_participant 'fedora_add_relationships' do |workitem|
  damxml = Nokogiri::XML(workitem.fields['__bag_DAMXML'])
  # ...
  # category
  unless damxml.xpath('//WGBH_TYPE/@ITEM_CATEGORY').first.nil?
     $fedora.addRelationship(:pid =>workitem.fields['identifier'], :relationship => 'info:fedora/fedora-system:def/relations-external#isMemberOfCollection', :object => 'info:fedora/org.wgbh.mla:' + damxml.xpath('//WGBH_TYPE/@ITEM_CATEGORY').first.to_s.parameterize, :isLiteral => false, :datatype => nil)     
  end
end
