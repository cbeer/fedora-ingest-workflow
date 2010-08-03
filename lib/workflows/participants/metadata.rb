$engine.register_participant 'build_rdf' do |workitem|
  link_type_to_dc = {
    'PARENT' => RDF::URI.new('info:fedora/fedora-system:def/relations-external#hasMember'),
    'CHILD' => RDF::URI.new('info:fedora/fedora-system:def/relations-external#isMemberOfCollection'),
    'CONTAINS' => RDF::URI.new('info:fedora/fedora-system:def/relations-external#hasPart'),
    'BELONGTO' => RDF::URI.new('info:fedora/fedora-system:def/relations-external#isPartOf'),
    'PLACEDGR' => RDF::URI.new('info:fedora/fedora-system:def/relations-external#hasThumbnail'),
    'ARTESIA.LINKTYPE.ISPLACEDGROF' => RDF::URI.new('info:fedora/fedora-system:def/relations-external#isThumbnailOf')
  }
  doc = Nokogiri::XML(workitem.fields['document'])
  entities = Hash[doc.internal_subset.children.map { |x| [x.name, x.system_id.split(":").last ] }]
  
  graph = RDF::Graph.new
  
  doc.xpath('//LINK').map do |l|
    add_link = true
    add_link &= (doc.xpath('//UOIS[@UOI_ID="' + entities[l.attribute('SOURCE').to_s] + '"]/WGBH_RIGHTS[@RIGHTS_TYPE="Web"]').first.text =~ /Not to be released/).nil? unless doc.xpath('//UOIS[@UOI_ID="' + entities[l.attribute('SOURCE').to_s] + '"]/WGBH_RIGHTS[@RIGHTS_TYPE="Web"]').first.nil?
    add_link &= !(doc.xpath('//UOIS[@UOI_ID="' + entities[l.attribute('SOURCE').to_s] + '"]/@NAME').first.to_s =~ /mov$/ and doc.xpath('//UOIS[@UOI_ID="' + entities[l.attribute('DESTINATION').to_s] + '"]/@NAME').first.to_s =~ /mov$/)
    add_link &= !(doc.xpath('//UOIS[@UOI_ID="' + entities[l.attribute('SOURCE').to_s] + '"]/WGBH_SOURCE[@SOURCE_TYPE="Digital Video Essence URL"]/@SOURCE').first.to_s =~ /mov$/ and doc.xpath('//UOIS[@UOI_ID="' + entities[l.attribute('DESTINATION').to_s] + '"]/WGBH_SOURCE[@SOURCE_TYPE="Digital Video Essence URL"]/@SOURCE').first.to_s =~ /mov$/)
    
    graph << [RDF::URI.new(entities[l.attribute('SOURCE').to_s]), link_type_to_dc[l.attribute('LINK_TYPE').to_s], RDF::URI.new(entities[l.attribute('DESTINATION').to_s])] if add_link
    case l.attribute('LINK_TYPE').to_s
      when 'PARENT'
        graph << [RDF::URI.new(entities[l.attribute('DESTINATION').to_s]), RDF::URI.new('info:fedora/fedora-system:def/relations-external#isMemberOfCollection'), RDF::URI.new(entities[l.attribute('SOURCE').to_s])] if add_link
        
      when 'CONTAINS'
        graph << [RDF::URI.new(entities[l.attribute('DESTINATION').to_s]), RDF::URI.new('info:fedora/fedora-system:def/relations-external#isPartOf'), RDF::URI.new(entities[l.attribute('SOURCE').to_s])] if add_link
        
    end
  end
  
  RDF::Writer.for(:ntriples).open(workitem.fields['bag_root'] + '/rdf.nt') do |writer|
    graph.each_statement do |s|
      writer << s
    end
  end
  true
end