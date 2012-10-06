require_relative '../lib/jruby_amazon_mws' 

module AmazonMWS
  describe Client, "#list_matching_products" do
     before do     
       service = AmazonMWS::MockService.new(:list_matching_products_response => "#{File.dirname(__FILE__)}/sample_responses/ListMatchingProductsResponse.xml") 
       @client = AmazonMWS::Client.new(:service => service)
     end 
     
     it 'returns the list of matching products given a string query' do 
       matching_products = @client.list_matching_products('Some Query')
       matching_products.should have(1).thing 
       product = matching_products.first
       product.asin.should eq('string')
       product.sales_rank_list.should have(1).thing      
     end
  end
end

