$engine.register_participant 'create_bag' do |workitem|
  BagIt::Bag.new workitem.fields['bag_root']
  true
end

$engine.register_participant 'validate_bag' do |workitem|
  true
end

$engine.register_participant 'populate_bag' do |workitem|
  bag = BagIt::Bag.new workitem.fields['bag_root']
  begin
  workitem.fields.select { |k,v| k =~ /__bag_/ }.each do |k,v|
    f = k.gsub(/__bag_/, '').gsub(/\.[a-z]+$/,'')
    if v =~ /^file:\/\//
      bag.add_file(workitem.fields['identifier'] + "/" + f) do |io|
        io.puts ''
      end
      FileUtils.rm workitem.fields['bag_root'] + '/data/' + workitem.fields['identifier'] + "/" + f
      FileUtils.ln_s v.gsub(/^file:\/\//,  ''), workitem.fields['bag_root'] + '/data/' + workitem.fields['identifier'] + "/" + f
    else      
      bag.add_file(workitem.fields['identifier'] + "/" + f) do |io|
        io.puts v
      end
    end
  end   
  rescue
  end
  true
end

$engine.register_participant 'add_to_bag' do |workitem|
  bag = BagIt::Bag.new workitem.fields['bag_root']
  bag.add_file(workitem.fields['identifier'] + "/" + workitem.params['file']) do |io|
    io.puts workitem.fields[workitem.params['from_f']]
  end
end

$engine.register_participant 'load_bag_object' do |workitem|
workitem.fields['object_path'] = workitem.fields['bag_root'] + '/data/' + workitem.fields['obj']
  workitem.fields['__bag_PBCore'] = open(workitem.fields['object_path'] + '/PBCore').read()
  workitem.fields['__bag_DC'] = open(workitem.fields['object_path'] + '/DC').read()
  workitem.fields['__bag_DAMXML'] = open(workitem.fields['object_path'] + '/DAMXML').read()
end

$engine.register_participant 'get_bag_objects' do |workitem|
  bag = BagIt::Bag.new workitem.fields['bag_root']
  objects = Dir.glob(bag.data_dir  + '/*').map { |x| x[/\/([^\/]*)$/, 1] }
  objects
end


