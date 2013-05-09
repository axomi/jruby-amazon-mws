Gem::Specification.new do |s|
  s.name = "jruby-amazon-mws"
  s.version = "0.0.1"
  s.platform = "java"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Sam-Bodden"]
  s.date = "2012-10-03"
  s.description = "JRuby client for Amazon Marketplace Web Service (Amazon MWS)"
  s.email = "bsbodden@integrallis.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "History.txt",
    "LICENSE",
    "Manifest.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/java/MaWSProductsJavaClientLibrary-1.0.jar",
    "lib/java/activation.jar",
    "lib/java/commons-codec-1.3.jar",
    "lib/java/commons-httpclient-3.0.1.jar",
    "lib/java/commons-logging-1.1.jar",
    "lib/java/jaxb-api.jar",
    "lib/java/jaxb-impl.jar",
    "lib/java/jaxb-xjc.jar",
    "lib/java/jsr173_1.0_api.jar",
    "lib/java/log4j-1.2.14.jar",
    "lib/jruby-amazon-mws/jruby_amazon_mws.rb",
    "lib/jruby_amazon_mws.rb",
    "lib/module/mws.rb"
  ]
  s.homepage = "http://github.com/integrallis/jruby-amazon-mws"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "JRuby client for Amazon MWS"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<crack>, [">= 0"])
      s.add_development_dependency(%q<hirb>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
    else
      s.add_dependency(%q<crack>, [">= 0"])
      s.add_dependency(%q<hirb>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
    end
  else
    s.add_dependency(%q<crack>, [">= 0"])
    s.add_dependency(%q<hirb>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
  end
end

