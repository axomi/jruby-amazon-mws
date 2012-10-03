require_relative '../lib/jruby_amazon_mws' 

module AmazonMWS
  describe Client, "#lowest_offer_for_asin" do
     before do
       @client = AmazonMWS::Client.new(:mock_service => true)
     end 
     
     it 'returns lowest price given an ASIN' do   
       lowest = @client.lowest_offer_for_asin('8675309') 
       lowest.should eq('1000.0') 
     end
  end
end

