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

matching_products = client.list_matching_products('Harry Potter')       
matching_products.each do |product|
  puts "==================================="
  puts "ASIN: #{product.asin}"
  puts "marketplace_id: #{product.marketplace_id}" 
  
  puts "attributes:"  
  product.attributes.each do |attribute|
    puts "  title: #{attribute.title}" 
    puts "  publisher: #{attribute.publisher}"  
    puts "  author: #{attribute.author}"  
    puts "  format: #{attribute.binding}"
  end   
  
  lowest = client.lowest_offer_for_asin(product.asin) 
  puts "lowest price: #{lowest}"
  
  puts "sales rank:" unless product.sales_rank_list.empty? 
  product.sales_rank_list.each do |sr|
    puts "  rank: #{sr.rank}, category: #{sr.category}"
  end
  puts "\n" 
end       