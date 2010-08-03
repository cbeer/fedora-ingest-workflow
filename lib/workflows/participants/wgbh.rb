$engine.register_participant 'sanitize_dam_xml' do |workitem|
  workitem.fields['document'] = workitem.fields['document'].gsub(/ROLE="([^\d"]+)[0-9]+"/, 'ROLE="\1"').gsub(/TYPE="([^\d"]+)[0-9]+"/, 'TYPE="\1"')
end

$engine.register_participant 'preprocess_dam_metadata' do |workitem|
  doc = Nokogiri::XML(workitem.fields['asset'])
  
  workitem.fields['identifier'] = doc.xpath('//UOIS/@UOI_ID').first.to_s
  
  
  bag = BagIt::Bag.new workitem.fields['bag_root']
  bag.add_file(workitem.fields['identifier'] + "/DAMXML") do |io|
    io.puts workitem.fields['asset']
  end
  
  workitem.fields['ok'] = true
  true
end

$engine.register_participant 'find_dam_asset' do |workitem|
  doc = Nokogiri::XML(workitem.fields['asset'])
  
  # .mp4  
  path = File.expand_path((Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s.gsub(/\.[a-z0-9]+$/, '.mp4')).first))
  
  # .mp3  
  path = File.expand_path((Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s.gsub(/\.[a-z0-9]+$/, '.mp3')).first)) unless File.file? path
  
  # .xml  
  path = File.expand_path((Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s.gsub(/\.[a-z0-9]+$/, '.xml')).first)) unless File.file? path
  
  path =  File.expand_path((Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s).first)) unless File.file? path
    
  'file://' + path
end

$engine.register_participant 'find_dam_asset_thumbnail' do |workitem|
  doc = Nokogiri::XML(workitem.fields['asset'])
  
  'file://' + File.expand_path((Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s.gsub(/\.[a-z0-9]+$/, '.jpg')).first) || '/dev/null')
end