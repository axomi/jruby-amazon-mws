require 'java'

require_relative '../../lib/java/jaxb-api.jar'
require_relative '../../lib/java/jaxb-impl.jar'
require_relative '../../lib/java/activation.jar'
require_relative '../../lib/java/jsr173_1.0_api.jar'
require_relative '../../lib/module/mws' 

java_import 'javax.xml.bind.JAXBContext'
java_import 'javax.xml.bind.JAXBException'
java_import 'javax.xml.bind.Unmarshaller'

module AmazonMWS
  class MockService
    include MWS::MarketplaceWebServiceProducts 
    
    class << self; attr_accessor :log end
    @log = org.apache.commons.logging.LogFactory.getLog(self.to_s) 
    
    def initialize(options)
      @list_matching_products_response = options[:list_matching_products_response]
      @lowest_offer_for_asin_response = options[:lowest_offer_for_asin_response]
    end
    
    def getLowestOfferListingsForASIN(request) 
      unmarshall(@lowest_offer_for_asin_response)
    end
    
    def list_matching_products(request)
      unmarshall(@list_matching_products_response)
    end
    
    protected
    
    def unmarshall(xml_file)
      ctx = JAXBContext.new_instance("com.amazonservices.mws.products.model")
      unmarshaller = ctx.create_unmarshaller
      unmarshaller.unmarshal(java.io.File.new(xml_file));
    rescue JAXBException => ex
      MockService.log.error "JAXB Unmarshalling failed because: #{ex.message}"
    end  
      
  end
end 