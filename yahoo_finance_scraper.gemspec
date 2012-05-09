# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yahoo_finance_scraper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Huned Botee"]
  gem.email         = ["huned@734m.com"]
  gem.summary       = %q{A scraper for Yahoo Finance in ruby.}
  gem.description   = %q{Scrape most active stocks, detailed stock quotes, historical prices, and options chain prices from Yahoo Finance with ruby.}
  gem.homepage      = "http://github.com/huned/yahoo_finance_scraper"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yahoo_finance_scraper"
  gem.require_paths = ["lib"]
  gem.version       = YahooFinance::Scraper::VERSION

  gem.add_dependency 'nokogiri'

  gem.add_development_dependency 'debugger'
  gem.add_development_dependency 'rspec'
end
