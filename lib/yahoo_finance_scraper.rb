require "yahoo_finance_scraper/version"
require "yahoo_finance_scraper/columns"
require 'csv'
require 'net/http'
require 'nokogiri'

module YahooFinance
  module Scraper
    class Company
      attr_reader :symbol
      attr_accessor :getter

      def initialize symbol, options = {}
        @symbol = symbol
        @getter = options[:getter]
      end

      def details
        name, *numeric_values = CSV.parse(get(details_url)).first
        Hash[COLUMNS.keys.zip([name] + numeric_values.map(&:to_f))]
      end

      def historical_prices from = nil, to = nil
        to ||= Date.today
        from ||= to - 731 # 2 years (+ 1 day in case of leap year)
        url = historical_prices_url from, to

        CSV.parse(get(url))[1..-1].map do |row|
          date, open, high, low, close, volume, adj_close = row
          { open: open.to_f, high: high.to_f, low: low.to_f,
            close: close.to_f, volume: volume.to_i,
            date: Date.strptime(date, '%Y-%m-%d').to_time }
        end.sort_by {|h| h[:date] }
      end

      def options_chain
        results = []
        url = options_chain_url

        doc = Nokogiri::HTML get(url)

        # current page
        results += parse_options_chain_doc doc

        # follow links to other expiration dates and parse those too
        anchors = doc.css '#yfncsumtab a[href^="/q/op?s=%s&m="]' % symbol.upcase
        anchors.each do |a|
          m = a['href'].match(/(&m=\d{4}-\d{2})/)[1]
          doc = Nokogiri::HTML get(url + m)
          results += parse_options_chain_doc doc
        end

        results
      end

      private

      def get url
        (getter && getter.get(url)) || Net::HTTP.get(URI.parse(url))
      end

      def details_url
        'http://download.finance.yahoo.com/d/quotes.csv?s=%s&f=%s' % [
          symbol,
          COLUMNS.values.join # just get everything
        ]
      end

      def historical_prices_url from, to
        'http://ichart.finance.yahoo.com/table.csv?s=%s&a=%s&b=%s&c=%s&d=%s&e=%s&f=%s&g=d&ignore=.csv' % [
          symbol, 
          from.month - 1,
          from.day,
          from.year,
          to.month - 1,
          to.day,
          to.year
        ]
      end

      def options_chain_url
        'http://finance.yahoo.com/q/op?s=%s' % symbol
      end

      def parse_options_chain_doc doc
        doc.css('.yfnc_datamodoutline1 table').map do |table|
          table.css('tr')[1..-1].map do |tr|
            name, data = parse_options_chain_tr tr
            { name => data }
          end
        end.flatten
      end

      def parse_options_chain_tr tr
        tds = tr.css 'td'
        strike, name, last, chg, bid, ask, volume, open_int = tds.map &:text

        # parse out expiry
        date_string = name.match(/#{symbol}(\d{6})/i)[1]
        expires_at = Date.strptime(date_string, '%y%m%d').to_time

        # parse out +/- change
        style = tds[3].css('b').first['style']
        change_direction = style =~ /#cc0000/i ? -1 : 1

        [
          name,
          { last: last.to_f, change: change_direction * chg.to_f,
            bid: bid.to_f, ask: ask.to_f, volume: volume.to_f,
            open_int: open_int.to_f, strike: strike.to_f,
            expires_at: expires_at }
        ]
      end
    end

    class Actives
      attr_accessor :getter

      def initialize options = {}
        @getter = options[:getter]
      end

      def losers ; fetch 'losers' ; end
      def gainers; fetch 'gainers'; end
      def actives; fetch 'actives'; end

      private

      def get url
        (getter && getter.get(url)) || Net::HTTP.get(URI.parse(url))
      end

      def fetch resource
        url_template = "http://finance.yahoo.com/#{resource}?e=%s"

        # for now, fetches across US exchanges only
        %w/us o aq nq/.map do |exchange|
          url = url_template % exchange
          doc = Nokogiri::HTML get(url)
          doc.css('#yfitp tbody tr').map do |tr|
            tds = tr.css 'td'
            { symbol: tds[0].text.strip.upcase, name: tds[1].text.strip }
          end
        end.flatten.compact.uniq
      end
    end
  end
end
