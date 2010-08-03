
require 'RMagick'
require 'tempfile'

# split an XML document into individual pieces
$engine.register_participant 'split_xml' do |workitem|
  Nokogiri::XML(workitem.fields['document']).xpath(workitem.params['xpath']).map { |x| x.to_s }
end

$engine.register_participant 'logger', Ruote::StorageParticipant

$engine.register_participant 'transform_xml_by_xslt' do |workitem|
  require 'xml/xslt'
  xslt = XML::XSLT.new
  xslt.xml = workitem.fields[workitem.params['from_f']]
  xslt.xsl = workitem.params['xslt'] 

  xslt.serve
end

$engine.register_participant 'upload_asset' do |workitem|
  true # process completely asynchronously...
end

$engine.register_participant 'create_thumbnail' do |workitem|
  return unless File.file? workitem.fields[workitem.params['from_f']].gsub(/^file:\/\//,  '')
  tmp = Tempfile.new workitem.fields['identifier'] + "_tn"
  path = tmp.path()
  tmp.close!
  tmp = nil
  
  img = Magick::Image.read(workitem.fields[workitem.params['from_f']]).first.sharpen(0,0.5)
  
    c = img.crop_resized(workitem.params['w'], workitem.params['h'], Magick::CenterGravity)
    c.write('jpg:' + path)
    
        
    c.destroy!
    img.destroy!
    
    "tmp://" +  path
end
