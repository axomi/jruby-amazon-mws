$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")) 

require 'jruby_amazon_mws'  
require 'yaml'

config = YAML::load(File.open("amazon-credentials.yaml"))

client = AmazonMWS::Client.new(
  :locale => config['locale'],
  :key => config['key'],
  :secret => config['secret'],
  :marketplace => config['marketplace'],
  :seller => config['seller'],
  :application_name => config['application_name'],
  :application_version => config['application_version']
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