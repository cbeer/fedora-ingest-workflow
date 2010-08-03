module WGBH
  class Workflow
    class << self
      def dam_to_bagit
        Ruote.process_definition :name => 'dam_to_bagit' do
          sequence do
            participant :ref => 'create_bag'
            participant :ref => 'sanitize_dam_xml'
            participant :ref => 'split_xml', :xpath => '//ASSET'
            iterator :on_f => '__result__', :to_f => 'asset' do
              sequence do
                participant :ref => 'preprocess_dam_metadata'
                
                participant :ref => 'find_dam_asset'
                participant :ref => 'add_to_bag', :file => 'File', :from_f => '__result__'
                
                participant :ref => 'find_dam_asset_thumbnail'
                set :f => '__bag_Thumbnail', :field_value => '__result__'
                participant :ref => 'add_to_bag', :file => 'Thumbnail', :from_f => '__result__'
                
                
                concurrence do
                  sequence do
                    participant :ref => 'transform_xml_by_xslt', :from_f => 'asset', :xslt => (File.dirname(__FILE__) + "/asset_to_pbcore.xsl")
                    participant :ref => 'add_to_bag', :file => 'PBCore', :from_f => '__result__'
                  end
                  sequence do
                    participant :ref => 'transform_xml_by_xslt', :from_f => 'asset', :to_f => 'dc', :xslt => (File.dirname(__FILE__) + "/asset_to_dc.xsl")
                    
                    participant :ref => 'add_to_bag', :file => 'DC', :from_f => '__result__'
                  end   
                    
                  create_thumbnails
                end
                
              end 
            end
            participant :ref => 'build_rdf'
          end
          
          define 'create_thumbnails' do
            concurrence do
              sequence do
                participant :ref =>'create_thumbnail', :from_f => '__bag_Thumbnail', :w => 320, :h => 240    
                participant :ref => 'add_to_bag', :file => '__tn_large', :from_f => '__result__'
              end                    
              sequence do
              participant :ref =>'create_thumbnail', :from_f => '__bag_Thumbnail', :w => 170, :h => nil  
              
              participant :ref => 'add_to_bag', :file => '__tn_preview', :from_f => '__result__'
              end
              sequence do
              participant :ref =>'create_thumbnail', :from_f => '__bag_Thumbnail', :w => 54, :h => 41
              
              participant :ref => 'add_to_bag', :file => '__tn_thumbnail', :from_f => '__result__'
              end
              sequence do
              participant :ref =>'create_thumbnail', :from_f => '__bag_Thumbnail', :w => 56, :h => 73
              
              participant :ref => 'add_to_bag', :file => '__tn_vertical', :from_f => '__result__'
              end
            end
          end
        end
      end
    end
  end
end