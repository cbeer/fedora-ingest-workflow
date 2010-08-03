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
                participant :ref => 'preprocess_dam_asset'
                
                participant :ref => 'transform_xml_by_xslt', :from_f => 'asset', :xslt => (File.dirname(__FILE__) + "/asset_to_pbcore.xsl")
                set :f => '__bag_PBCore', :field_value => '__result__'
                participant :ref => 'transform_xml_by_xslt', :from_f => 'asset', :to_f => 'dc', :xslt => (File.dirname(__FILE__) + "/asset_to_dc.xsl")    
                set :f => '__bag_DC', :field_value => '__result__'
                
                participant :ref => 'handle_thumbnails'
                
                participant :ref => 'populate_bag', :if => '${f:ok}'
              end 
            end
            participant :ref => 'build_rdf'
          end
        end
      end
    end
  end
end