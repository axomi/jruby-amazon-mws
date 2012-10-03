#--
# Copyright &169;2001-2013 Integrallis Software, LLC. 
# All Rights Reserved.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'rubygems'  
require 'java' 
require 'module/mws' 
require 'bigdecimal'
require 'crack/xml' 
require 'ostruct'

module AmazonMWS
  class Client 
    attr_reader :locale, :key, :secret, :marketplace, :seller, :application_name, :application_version  
    
    def initialize(options)      
      # extract options
      @locale = options[:locale]
      @key = options[:key]
      @secret = options[:secret]
      @marketplace = options[:marketplace]
      @seller = options[:seller]
      @application_name = options[:application_name] 
      @application_version = options[:application_version]
      mock_service = options[:mock_service] || false 
      # configure the underlying Java service  
      config = MWS::MarketplaceWebServiceProductsConfig.new 
      config.service_url = service_url_for_locale(self.locale)  
      unless mock_service
        @service = MWS::MarketplaceWebServiceProductsClient.new(
  				self.key, 
  				self.secret, 
  				self.application_name, 
  				self.application_version, 
  				config
  			) 
  		else 
  		  @service = MWS::MarketplaceWebServiceProductsMock.new
		  end
    end
    
    # TODO: need to add try() to check for nils
    def lowest_offer_for_asin(asin) 
      asin_list = MWS::ASINListType.new(java.util.Arrays.asList([asin].to_java))
      request = MWS::GetLowestOfferListingsForASINRequest.new(self.seller, self.marketplace, asin_list, "USED", false)
      response = @service.getLowestOfferListingsForASIN(request)  
      result = response.get_lowest_offer_listings_for_asin_result.first
      lowest_offer_listings = result.product.lowest_offer_listings.lowest_offer_listing
      lowest_offer = lowest_offer_listings.map { |item| BigDecimal(item.price.listing_price.amount.to_s) }.min
      lowest_offer.nil? ? nil : lowest_offer.to_s(' F').strip 
    end  
    
    def list_matching_products(query, category = :all)
      begin
        request = MWS::ListMatchingProductsRequest.new(self.seller, self.marketplace, query, US_QUERY_CONTEXT_VALUES[category])
        response = @service.list_matching_products(request)
        result = response.get_list_matching_products_result 
        
        matching_products = []

        if response.set_list_matching_products_result?
          list_matching_products_result = response.list_matching_products_result
          if list_matching_products_result.set_products?
            products = list_matching_products_result.products
            product_list = products.product
            product_list.each do |product|  
              matching_product = OpenStruct.new
              
              if product.set_identifiers?  
                identifiers = product.identifiers 
                
                if identifiers.isSetMarketplaceASIN
                  marketplace_asin = identifiers.getMarketplaceASIN 
                  matching_product.asin = marketplace_asin.asin if marketplace_asin.set_asin?
                  matching_product.marketplace_id = marketplace_asin.marketplace_id if marketplace_asin.set_marketplace_id?
                end
                  
                if identifiers.isSetSKUIdentifier  
                  sku_identifier = identifiers.getSKUIdentifier 
                  matching_product.sku_identifier = OpenStruct.new
                  matching_product.sku_identifier.marketplace_id = sku_identifier.marketplace_id
                  #puts "sku_identifier.marketplace_id ==> #{sku_identifier.marketplace_id}" if sku_identifier.set_marketplace_id?
                  #puts "sku_identifier.seller_id ==> #{sku_identifier.seller_id}" if sku_identifier.set_seller_id?
                  #puts "sku_identifier.seller_s_k_u ==> #{sku_identifier.seller_s_k_u}" if sku_identifier.set_seller_s_k_u?
                end 
              end 
               
              if product.set_attribute_sets?
                attribute_set_list = product.attribute_sets        
                matching_product.attributes = []
                attribute_set_list.any.each do |attribute_set|
                  attributes_set_parsed = Crack::XML.parse(MWS::ProductsUtil.format_xml(attribute_set))
                  item_attributes = attributes_set_parsed["ns2:ItemAttributes"] 
                  attributes = OpenStruct.new   
                  if item_attributes
                    item_attributes.delete "xmlns:ns2" 
                    item_attributes.delete "xmlns"
                    item_attributes.each_pair do |key,value|
                      # remove the ns2: from key, underscore and add to the attributes struct 
                      # TODO (need to do this recursively)
                      attributes.send(%[#{key.gsub("ns2:", "").underscore}=], value)
                    end 
                  end
                  matching_product.attributes << attributes
                end
              end  
              
              if product.set_relationships?
                relationships = product.relationships
                relationships.any.each do |relationship| 
                  relationships = Crack::XML.parse(MWS::ProductsUtil.format_xml(relationship))
                  #puts "relationships ==> #{relationships}" 
                end
              end 
                          
              if product.set_competitive_pricing?
                competitive_pricing = product.competitive_pricing
                if competitive_pricing.set_competitive_prices?
                  competitive_prices = competitive_pricing.competitive_prices
                  competitive_price_list = competitive_prices.competitive_price 
                  matching_product.competitive_pricing_list = []
                  competitive_price_list.each do |competitive_price| 
                    matching_product_competitive_price = OpenStruct.new
                    matching_product_competitive_price.condition = competitive_price.condition if competitive_price.set_condition?
                    matching_product_competitive_price.subcondition = competitive_price.subcondition if competitive_price.set_subcondition?
                    matching_product_competitive_price.belongs_to_requester = competitive_price.belongs_to_requester if competitive_price.set_belongs_to_requester?
                    matching_product_competitive_price.competitive_price_id = competitive_price.competitive_price_id if competitive_price.set_competitive_price_id?
                    
                    if competitive_price.set_price?
                      price = competitive_price.price
                      if price.set_landed_price?
                        landed_price = price.landed_price  
                        matching_product_competitive_price.landed_price_currency_code = landed_price.currency_code if landed_price.set_currency_code?
                        matching_product_competitive_price.landed_price_amount = landed_price.amount if landed_price.set_amount?
                      end
                       
                      if price.set_listing_price?
                        listing_price = price.listing_price 
                        matching_product_competitive_price.listing_price_currency_code = listing_price.currency_code if listing_price.set_currency_code? 
                        matching_product_competitive_price.listing_price_amount = listing_price.amount if listing_price.set_amount?
                      end
                      
                      if price.set_shipping?
                        shipping = price.shipping
                        matching_product_competitive_price.shipping_currency_code = shipping.currency_code if shipping.set_currency_code?
                        matching_product_competitive_price.shipping_amount = shipping.amount if shipping.set_amount?
                      end 
                    end                   
                    matching_product.competitive_pricing_list << matching_product_competitive_price
                  end
                end
                 
                if competitive_pricing.set_number_of_offer_listings?
                  number_of_offer_listings = competitive_pricing.number_of_offer_listings
                  offer_listing_count_list = number_of_offer_listings.offer_listing_count
                  offer_listing_count_list.each do |offer_listing_count|
                    #puts "offer_listing_count.condition ==> #{offer_listing_count.condition}" if offer_listing_count.set_condition? 
                    #puts "offer_listing_count.value ==> #{offer_listing_count.value}" if offer_listing_count.set_value? 
                  end
                end 
                
                if competitive_pricing.set_trade_in_value?
                  trade_in_value = competitive_pricing.trade_in_value
                  #puts "trade_in_value.currency_code ==> #{trade_in_value.currency_code}" if trade_in_value.set_currency_code?
                  #puts "trade_in_value.amount ==> #{trade_in_value.amount}" if trade_in_value.set_amount?
                end 
                 
              end 
                
              if product.set_sales_rankings?
                sales_rankings = product.sales_rankings
                sales_rank_list = sales_rankings.sales_rank 
                matching_product.sales_rank_list = []
                sales_rank_list.each do |sales_rank| 
                  matching_product_sales_rank = OpenStruct.new
                  matching_product_sales_rank.category = sales_rank.product_category_id if sales_rank.set_product_category_id?
                  matching_product_sales_rank.rank = sales_rank.rank if sales_rank.set_rank? 
                  matching_product.sales_rank_list << matching_product_sales_rank
                end
              end 
                       
              if product.set_lowest_offer_listings?
                lowest_offer_listings = product.lowest_offer_listings
                lowest_offer_listing_list = lowest_offer_listings.lowest_offer_listing
                lowest_offer_listing_list.each do |lowest_offer_listing|
                  if lowest_offer_listing.set_qualifiers?
                    qualifiers = lowest_offer_listing.qualifiers
                    # puts "qualifiers.item_condition ==> #{qualifiers.item_condition}" if qualifiers.set_item_condition?
                    # puts "qualifiers.item_subcondition ==> #{qualifiers.item_subcondition}" if qualifiers.set_item_subcondition?
                    # puts "qualifiers.fulfillment_channel ==> #{qualifiers.fulfillment_channel}" if qualifiers.set_fulfillment_channel?
                    # puts "qualifiers.ships_domestically ==> #{qualifiers.ships_domestically}" if qualifiers.set_ships_domestically?
                    
                    if qualifiers.set_shipping_time?
                      shipping_time = qualifiers.shipping_time
                      #puts "shipping_time.max ==> #{shipping_time.max}" if shipping_time.set_max? 
                    end 
                    
                    #puts "qualifiers.seller_positive_feedback_rating ==> #{qualifiers.seller_positive_feedback_rating}" if qualifiers.set_seller_positive_feedback_rating?
                  end
                  
                  #puts "lowest_offer_listing.number_of_offer_listings_considered ==> #{lowest_offer_listing.number_of_offer_listings_considered}"
                  #puts "lowest_offer_listing.seller_feedback_count ==> #{lowest_offer_listing.seller_feedback_count}" if lowest_offer_listing.set_seller_feedback_count?
                  
                  if lowest_offer_listing.set_price?
                    price1 = lowest_offer_listing.price
                    if price1.set_landed_price?
                      landed_price1 = price1.landed_price
                      #puts "landed_price1.currency_code ==> #{landed_price1.currency_code}" if landed_price1.set_currency_code?
                      #puts "landed_price1.amount ==> #{landed_price1.amount}" if landed_price1.set_amount? 
                    end
                    
                    if price1.set_listing_price?
                      listing_price1 = price1.listing_price
                      #puts "listing_price1.currency_code ==> #{listing_price1.currency_code}" if listing_price1.set_currency_code?
                      #puts "listing_price1.amount ==> #{listing_price1.amount}" if listing_price1.set_amount?
                    end
                     
                    if price1.set_shipping?
                      shipping1 = price1.shipping
                      #puts "shipping1.currency_code ==> #{shipping1.currency_code}" if shipping1.set_currency_code?
                      #puts "shipping1.amount ==> #{shipping1.amount}" if shipping1.set_amount? 
                    end 
                  end 
               
                  #puts "lowest_offer_listing.multiple_offers_at_lowest_price ==> #{lowest_offer_listing.multiple_offers_at_lowest_price}" if lowest_offer_listing.set_multiple_offers_at_lowest_price?
                end 
              end  
              
              if product.set_offers?       
                offers = product.offers
                offer_list = offers.offer
                
                offer_list.each do |offer|
                  if offer.set_buying_price?
                    buying_price = offer.buying_price
                    if buying_price.set_landed_price?
                      landed_price2 = buying_price.landed_price
                      #puts "landed_price2.currency_code ==> #{landed_price2.currency_code}" if landed_price2.set_currency_code?
                      #puts "landed_price2.amount ==> #{landed_price2.amount}" if landed_price2.set_amount?
                    end  
                                        
                    if buying_price.set_listing_price?
                      listing_price2 = buying_price.listing_price
                      #puts "listing_price2.currency_code ==> #{listing_price2.currency_code}" if listing_price2.set_currency_code? 
                      #puts "listing_price2.amount ==> #{listing_price2.amount}" if listing_price2.set_amount? 
                    end
                     
                    if buying_price.set_shipping?
                      shipping2 = buying_price.shipping
                      #puts "shipping2.currency_code ==> #{shipping2.currency_code}" if shipping2.set_currency_code?
                      #puts "shipping2.amount ==> #{shipping2.amount}" if shipping2.set_amount? 
                    end 
                  end 
                  
                  if offer.set_regular_price?
                    regular_price = offer.regular_price
                    #puts "regular_price.currency_code ==> #{regular_price.currency_code}" if regular_price.set_currency_code?
                    #puts "regular_price.amount ==> #{regular_price.amount}" if regular_price.set_amount? 
                  end
                   
                  #puts "offer.fulfillment_channel ==> #{offer.fulfillment_channel}" if offer.set_fulfillment_channel?  
                  #puts "offer.item_condition ==> #{offer.item_condition}" if offer.set_item_condition?
                  #puts "offer.item_sub_condition ==> #{offer.item_sub_condition}" if offer.set_item_sub_condition?
                  #puts "offer.seller_id ==> #{offer.seller_id}" if offer.set_seller_id?
                  #puts "offer.getSellerSKU ==> #{offer.getSellerSKU}" if offer.isSetGetSellerSKU
                end
              end         
            
              matching_products << matching_product
            end    
          end 
        end
   
        if response.set_response_metadata?
          response_metadata = response.response_metadata
          #puts "response_metadata.request_id ==> #{response_metadata.request_id}" if response_metadata.set_request_id? 
        end 
        #puts "response.response_header_metadata ==> #{response.response_header_metadata}"
         
        matching_products
         
      rescue MWS::MarketplaceWebServiceProductsException => ex
        $stderr.print "Caught Exception: #{ex.message}" 
        $stderr.print "Response Status Code:  #{ex.status_code}"
        $stderr.print "Error Code:  #{ex.error_code}"
        $stderr.print "Error Type:  #{ex.error_type}"
        $stderr.print "Request ID:  #{ex.request_id}"
        $stderr.print "XML:  #{ex.xml}"
        $stderr.print "ResponseHeaderMetadata:  #{ex.response_header_metadata}"
      end
    end
    
    protected 
    
    def service_url_for_locale(locale)
      case locale
      when "US"
        "https://mws.amazonservices.com/Products/2011-10-01"
      when "CA"
        "https://mws.amazonservices.ca/Products/2011-10-01"
      when "EU"
        "https://mws-eu.amazonservices.com/Products/2011-10-01"
      when "JP"
        "https://mws.amazonservices.jp/Products/2011-10-01" 
      when "CN"
        "https://mws.amazonservices.com.cn/Products/2011-10-01"
      else
        "https://mws.amazonservices.com/Products/2011-10-01"
      end
    end   
       
    # TODO: add the other locales
    def query_context_values_for_locale(locale)
      case locale
      when "US"
        US_QUERY_CONTEXT_VALUES 
      else
        US_QUERY_CONTEXT_VALUES
      end
    end
    
    US_QUERY_CONTEXT_VALUES = { 
      :all => "All",
      :apparel => "Apparel",
      :appliances => "Appliances",
      :arts_and_crafts => "ArtsAndCrafts",
      :automotive => "Automotive",
      :baby => "Baby",
      :beauty => "Beauty",
      :books => "Books",
      :classical => "Classical", 
      :digital_music => "DigitalMusic",
      :dvd => "DVD",
      :electronics => "Electronics",
      :grocery => "Grocery",
      :health_personal_care => "HealthPersonalCare",
      :home_garden => "HomeGarden",
      :industrial => "Industrial",
      :jewelry => "Jewelry",
      :kindle_store => "KindleStore",
      :kitchen => "Kitchen",
      :magazines => "Magazines",
      :miscellaneous => "Miscellaneous",
      :mobile_apps => "MobileApps",
      :mp3_downloads => "MP3Downloads",
      :music => "Music",
      :musical_instruments => "MusicalInstruments",
      :office_products => "OfficeProducts",
      :pc_hardware => "PCHardware",
      :pet_supplies => "PetSupplies",
      :photo => "Photo",
      :shoes => "Shoes",
      :software => "Software",
      :sporting_goods => "SportingGoods",
      :tools => "Tools",
      :toys => "Toys",
      :unbox_video => "UnboxVideo",
      :vhs => "VHS",
      :video => "Video",
      :video_games => "VideoGames",
      :watches => "Watches",
      :wireless => "Wireless",
      :wireless_accessories => "WirelessAccessories" 
    }

  end   
end   