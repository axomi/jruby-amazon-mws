A JRuby Library to access Amazon MWS
==================================== 

A JRuby Library to acess the Amazon Marketplace Web Service (Amazon MWS) API version released on  2011-10-01 using the JAXB Java Bindings provided at :

https://images-na.ssl-images-amazon.com/images/G/01/mwsportal/clientlib/products/amazon-mws-v20111001-java-2012-07-01._V388353362_.zip 

For more information on the backing library see https://developer.amazonservices.com/doc/products/products/v20111001/java.html

Prerequisites
-------------

An Amazon Pro Merchant seller account or another Amazon account that makes you eligible to use Amazon Marketplace Web Service (Amazon MWS). For more information, see the Amazon MWS FAQ (https://developer.amazonservices.com/gp/mws/faq.html/190-8227795-5734439#mwsSellers).
    
Registering for Amazon MWS. For more information see the Amazon MWS FAQ.
    
This Gem targets the JRuby (1.6.x - 1.7.x) distributions. 

Usage
----- 

All API access is through the class AmazonMWS::Client

```
require 'jruby_amazon_mws'

client = AmazonMWS::Client.new(
  :locale => 'US',
  :key => 'YOUR_AMAZON_KEY',
  :secret => 'YOUR_AMAZON_SECRET',
  :marketplace => 'YOUR_AMAZON_MARKETPLACE_ID',
  :seller => 'YOUR_AMAZON_SELLER_ID',
  :application_name => 'YOUR_APPLICATION_NAME',
  :application_version => 'YOUR_APPLICATION_VERSION'
)                                                   

matching_products = client.list_matching_products('Harry Potter')       
matching_products.each do |product|

  puts "Found product with ASIN: #{product.asin}"
  puts "marketplace_id: #{product.marketplace_id}" 
   
  product.attributes.each do |attribute|
    puts "  title: #{attribute.title}" 
    puts "  publisher: #{attribute.publisher}"  
    puts "  author: #{attribute.author}"  
    puts "  format: #{attribute.binding}"
  end   
  
  puts "sales rank:" unless product.sales_rank_list.empty? 
  product.sales_rank_list.each do |sr|
    puts "  rank: #{sr.rank}, category: #{sr.category}"
  end

  lowest = client.lowest_offer_for_asin(product.asin)
  puts "lowest price: #{lowest}"
end
``` 

Writing Tests
------------- 

To simplify the writing of test a mock service implementation is provided that can be passed to a Client instance. The mock service can be configure to respond with a canned XML response as follows:

```
require 'jruby_amazon_mws'  

module AmazonMWS
  describe Client, "#lowest_offer_for_asin" do
     before do 
       service = AmazonMWS::MockService.new(:lowest_offer_for_asin_response => "GetLowestOfferListingsForASINResponse.xml") 
       @client = AmazonMWS::Client.new(:service => service)
     end 
     
     it 'returns lowest price given an ASIN' do   
       lowest = @client.lowest_offer_for_asin('8675309') 
       lowest.should eq('1000.0') 
     end
  end
end
```   

Sample responses for you application can be constructure with the 
Amazon MWS Scratchpad found at https://mws.amazonservices.com/scratchpad/index.html 

Examples
--------

See usage examples under /examples directory of this distribution

Contact
-------

Authors:: Brian Sam-Bodden, Danny Whalen
Email:: bsbodden@integrallis.com, dwhalen@integrallis.com
Home Page:: http://integrallis.com
License:: MIT Licence (http://www.opensource.org/licenses/mit-license.html)