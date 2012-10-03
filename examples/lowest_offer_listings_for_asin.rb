$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")) 

require 'jruby_amazon_mws' 

client = AmazonMWS::Client.new(
  :locale => 'US',
  :key => 'AKIAJ267FAM22J74RT7A',
  :secret => '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',
  :marketplace => 'ATVPDKIKX0DER',
  :seller => 'A3G6WNDFMU2LTW',
  :application_name => 'integrallis_jruby_amazon_mws_client',
  :application_version => '0.0.1'
)  

lowest = client.lowest_offer_for_asin('059035342X')       
puts "The lowest price is ==> #{lowest}"