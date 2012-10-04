#!/usr/bin/env ruby
 
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
    
require_relative '../java/MaWSProductsJavaClientLibrary-1.0.jar'
require_relative '../java/jsr173_1.0_api.jar'
require_relative '../java/activation.jar'                          
require_relative '../java/jaxb-api.jar'                                             
require_relative '../java/jaxb-impl.jar'
require_relative '../java/jaxb-xjc.jar'
require_relative '../java/commons-logging-1.1.jar'                 
require_relative '../java/commons-codec-1.3.jar'                   
require_relative '../java/commons-httpclient-3.0.1.jar'  
require_relative '../java/log4j-1.2.14.jar'
                             
module MWS
  include_package 'com.amazonservices.mws.products'
  include_package 'com.amazonservices.mws.products.model' 
  include_package 'com.amazonservices.mws.products.mock'
end      

 
