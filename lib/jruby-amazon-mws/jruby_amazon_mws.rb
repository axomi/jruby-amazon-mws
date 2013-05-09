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
      @service = options[:service]   
      
      unless @service
        # configure the underlying Java service  
        config = MWS::MarketplaceWebServiceProductsConfig.new 
        config.service_url = service_url_for_locale(self.locale)  
      
        @service = MWS::MarketplaceWebServiceProductsClient.new(
    			self.key, 
    			self.secret, 
    			self.application_name, 
    			self.application_version, 
    			config
    		) 
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
              
              _configure_product_identifiers(product, matching_product)
              _configure_product_attribute(product, matching_product)
              _configure_product_pricing(product, matching_product)  
              _configure_product_sales_rankings(product, matching_product)
              _configure_product_lowest_offer(product, matching_product) 
              _configure_product_offers(product, matching_product)
              
              # if product.set_relationships?
              #   relationships = product.relationships
              #   relationships.any.each do |relationship| 
              #     relationships = Crack::XML.parse(MWS::ProductsUtil.format_xml(relationship))
              #   end
              # end 

              matching_products << matching_product
            end    
          end 
        end
   
        if response.set_response_metadata?
          response_metadata = response.response_metadata
        end 
         
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
    
    private 
    
    def _configure_product_identifiers(product, matching_product)
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
        end 
      end
    end
    
    def _configure_product_attribute(product, matching_product)
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
    end
    
    def _configure_product_pricing(product, matching_product)            
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
        end 
      
        if competitive_pricing.set_trade_in_value?
          trade_in_value = competitive_pricing.trade_in_value
        end 
       
      end
    end

    def _configure_product_sales_rankings(product, matching_product)  
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
    end
    
    def _configure_product_lowest_offer(product, matching_product)         
      if product.set_lowest_offer_listings?
        lowest_offer_listings = product.lowest_offer_listings
        lowest_offer_listing_list = lowest_offer_listings.lowest_offer_listing
        lowest_offer_listing_list.each do |lowest_offer_listing|
          if lowest_offer_listing.set_qualifiers?
            qualifiers = lowest_offer_listing.qualifiers
          
            if qualifiers.set_shipping_time?
              shipping_time = qualifiers.shipping_time
            end 
          
          end
                          
          if lowest_offer_listing.set_price?
            price1 = lowest_offer_listing.price
            if price1.set_landed_price?
              landed_price1 = price1.landed_price
            end
          
            if price1.set_listing_price?
              listing_price1 = price1.listing_price
            end
           
            if price1.set_shipping?
              shipping1 = price1.shipping
            end 
          end 
     
        end 
      end
    end
    
    def _configure_product_offers(product, matching_product)     
      offer_list = product.set_offers? ? product.offers.offer : []
    
      offer_list.to_a.keep_if {|offer| offer.set_buying_price? }.each do |offer|
        buying_price = offer.buying_price
        landed_price2 = buying_price.landed_price if buying_price.set_landed_price?
        listing_price2 = buying_price.listing_price if buying_price.set_listing_price?
        shipping2 = buying_price.shipping if buying_price.set_shipping?
        regular_price = offer.regular_price if offer.set_regular_price?               
      end
    end

  end   
end   