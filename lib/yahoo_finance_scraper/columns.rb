module YahooFinance
  module Scraper
    class Company
      # adapted from http://www.gummy-stuff.org/Yahoo-data.htm
      COLUMNS = {
        name:               'n',
        dividend_per_share: 'd',
        earnings_per_share: 'e',
        price_to_sales:     'p5',
        price_to_book:      'p6',
        price_to_earnings:  'r',
        peg_ratio:          'r5',
        short_ratio:        's7',
        dividend_yield:     'y'
      }
    end
  end
end
