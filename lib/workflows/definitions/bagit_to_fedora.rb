module WGBH
  class Workflow
    class << self
      def bagit_to_fedora
        Ruote.process_definition :name => 'bagit_to_fedora' do
         sequence do
            participant :ref => 'validate_bag'
            participant :ref => 'create_bag'
       #     participant :ref => 'fedora_ingest_collection_object'
            participant :ref => 'get_bag_objects'
            iterator :on_f => '__result__', :to_f => 'obj' do
              ingest_object
            end
          end
        
          define 'ingest_object' do
            participant :ref => 'load_bag_object'         
            participant :ref => 'prepare_object'
            _if :test => '${f:__result__}' do
              sequence do
                participant :ref => 'mint_identifier'
                participant :ref => 'upload_asset'
                participant :ref => 'fedora_ingest_object'
                participant :ref => 'fedora_ingest_media_object'
              	participant :ref => 'fedora_add_relationships'
              end
            end
          end        
        end
      end
    end
  end
end