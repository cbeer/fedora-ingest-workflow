$engine.register_participant 'create_bag' do |workitem|
  BagIt::Bag.new workitem.fields['bag_root']
  true
end

$engine.register_participant 'validate_bag' do |workitem|
  true
end

def add_to_bag bag_root, object, h
  bag = BagIt::Bag.new bag_root
  h.each do |k,v|
    f = k.gsub(/__bag_/, '').gsub(/\.[a-z]+$/,'')
    
    if v =~ /^tmp:\/\//i
      bag.add_file(object + "/" + f, v.gsub(/^tmp:\/\//,  ''))
      FileUtils.rm v.gsub(/^tmp:\/\//,  '')
      next 
    end
    
    if v =~ /^file:\/\//
      
      
      bag.add_file(object + "/" + f) do |io|
        io.puts ''
      end
      FileUtils.rm bag.data_dir + "/" + object + "/" + f
      FileUtils.ln_s v.gsub(/^file:\/\//,  ''),bag.data_dir + "/" + object + "/" + f
      next
    end
          
    bag.add_file(object + "/" + f) do |io|
      io.puts v
    end
  end
end

$engine.register_participant 'add_to_bag' do |workitem|
  add_to_bag workitem.fields['bag_root'], workitem.fields['identifier'], {workitem.params['file'] => workitem.fields[workitem.params['from_f']]}
  true
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


