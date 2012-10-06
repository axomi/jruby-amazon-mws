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

lowest = client.lowest_offer_for_asin('059035342X')       
puts "The lowest price is ==> #{lowest}"