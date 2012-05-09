# YahooFinance::Scraper

Scrape most active stocks, detailed stock quotes, historical prices, and
options chain prices from Yahoo Finance with ruby.

See [http://github.com/huned/yahoo_finance_scraper](http://github.com/huned/yahoo_finance_scraper)

## Installation

Add this line to your application's Gemfile:

    gem 'yahoo_finance_scraper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yahoo_finance_scraper

## Usage

By default, assumes you want to get data with Net::HTTP.

Get historical daily stock prices:

    # Get historical daily stock prices of yhoo.
    # Note that `from` and `to` are both optional.
    YahooFinance::Company.new('yhoo').historical_prices(from, to)

returns:

    [ { :open => 15.51,
        :high => 15.73,
        :low => 15.5,
        :close => 15.63,
        :volume => 9799300,
        :date => 2012-05-01 00:00:00 -0700 },
      { :open => 15.58,
        :high => 15.77,
        :low => 15.54,
        :close => 15.67,
        :volume => 10841000,
        :date => 2012-05-02 00:00:00 -0700 },
      ... ]

Get current options chain:

    # Get the current options chain
    YahooFinance::Company.new('yhoo').options_chain

returns:

    # note that you can extract the symbol, expiry, put/call, and strike
    # from the option symbol string.
    [ { "YHOO120519C00009000" =>
        { :last => 6.1,
          :change => 0.0,
          :bid => 0.0,
          :ask => 0.0,
          :volume => 5.0,
          :open_int => 5.0,
          :strike => 9.0,
          :expires_at => 2012-05-19 00:00:00 -0700 } },
     { "YHOO120519C00010000" =>
        { :last => 5.7,
          :change => 0.0,
          :bid => 0.0,
          :ask => 0.0,
          :volume => 20.0,
          :open_int => 107.0,
          :strike => 10.0,
          :expires_at => 2012-05-19 00:00:00 -0700 } },
     ... ]

Get the day's actives, % gainers, and % losers:

    YahooFinance::Actives.new.actives # or #gainers or #losers

returns:

    [ { :symbol => "FOSL", :name => "Fossil, Inc." },
      { :symbol => "MAKO", :name => "MAKO Surgical Corp." },
      { :symbol => "MRGE", :name => "Merge Healthcare Incorporated." },
      ... ]

You can also control how the http GET happens. Just instantiate with a
getter that implements a `get` method that takes a single string argument
and returns the body of the request as a string.

    class CustomGetter
      def get url
        # get the url and return its contents as a string
      end
    end

    YahooFinance::Company.new('yhoo', getter: CustomGetter.new)
    YahooFinance::Actives.new(getter: CustomGetter.new)

Why have a custom getter? Because maybe you want to proxy via Tor so you
don't get cut off for making lots of requests. See
[Tor::Proxy](http://github.com/huned/tor_proxy) for a helpful gem.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
