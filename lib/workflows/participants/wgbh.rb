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

$engine.register_participant 'preprocess_dam_asset' do |workitem|
  doc = Nokogiri::XML(workitem.fields['asset'])
  
  # .mp4  
  workitem.fields['__bag_File'] = 'file://' + (Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s.gsub(/\.[a-z0-9]+$/, '.mp4')).first || '/dev/null')
  
  # .mp3  
  workitem.fields['__bag_File'] = 'file://' + (Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s.gsub(/\.[a-z0-9]+$/, '.mp3')).first || '/dev/null') unless File.file?(workitem.fields['__bag_File'])
  
  # .xml  
  workitem.fields['__bag_File'] = 'file://' + (Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s.gsub(/\.[a-z0-9]+$/, '.xml')).first || '/dev/null') unless File.file?(workitem.fields['__bag_File'])
  
  workitem.fields['__bag_File'] = 'file://' + (Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s).first || '/dev/null') unless File.file?(workitem.fields['__bag_File'])
  
  workitem.fields['__bag_Thumbnail'] = 'file://' + (Dir.glob(ASSET_BASE_PATH + '/**/' + doc.xpath('//UOIS/@NAME').first.to_s.gsub(/\.[a-z0-9]+$/, '.jpg')).first || '/dev/null')
  true
end