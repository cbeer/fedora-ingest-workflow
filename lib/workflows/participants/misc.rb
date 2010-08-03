
require 'RMagick'

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



$engine.register_participant 'handle_thumbnails' do |workitem|
  return unless File.file? workitem.fields['__bag_Thumbnail'].gsub(/^file:\/\//,  '')
  
  img = Magick::Image.read(workitem.fields['__bag_Thumbnail']).first.sharpen(0,0.5)

  c = img.crop_resized(320, 240, Magick::CenterGravity)
  c.write('jpg:' + workitem.fields['bag_root'] + '/data/' + workitem.fields['identifier'] + '/__tn_large')
  c.destroy!

  c = img.crop_resized(170, nil, Magick::CenterGravity)
  c.write('jpg:' + workitem.fields['bag_root'] + '/data/' + workitem.fields['identifier'] + '/__tn_preview')
  c.destroy!

  c = img.crop_resized(54, 41, Magick::CenterGravity)
  c.write('jpg:' + workitem.fields['bag_root'] + '/data/' + workitem.fields['identifier'] + '/__tn_thumbnail')
  c.destroy!

  c = img.crop_resized(56, 73, Magick::CenterGravity)
  c.write('jpg:' + workitem.fields['bag_root'] + '/data/' + workitem.fields['identifier'] + '/__tn_vertical')
  c.destroy!

  img.destroy!
  true
end