require 'yahoo_finance_scraper'

describe YahooFinance::Scraper do
  describe YahooFinance::Scraper::Company do
    describe '.new' do
      before do
        @scraper = YahooFinance::Scraper::Company.new 'yhoo'
      end

      it 'should default to Net::HTTP as getter' do
        @scraper.getter.should == Net::HTTP
      end
    end

    describe '#details' do
      before do
        @getter = mock :getter
        @getter.stub(:get).with kind_of(String) do
          File.read 'spec/fixtures/details.csv'
        end
        @scraper = YahooFinance::Scraper::Company.new 'yhoo', getter: @getter
        @details = @scraper.details
      end

      it 'should get details' do
        @details.keys.should == YahooFinance::Scraper::Company::COLUMNS.keys
        @details[:name].should == 'Yahoo! Inc.'
      end
    end

    describe '#historical_prices' do
      before do
        @getter = mock :getter
        @getter.stub(:get).with kind_of(String) do
          File.read 'spec/fixtures/historical_daily.csv'
        end
        @scraper = YahooFinance::Scraper::Company.new 'yhoo', getter: @getter
      end

      it 'should get historical prices' do
        @scraper.historical_prices.should be_all do |h|
          h.keys.sort == [ :close, :date, :high, :low, :open, :volume ]
        end
      end
    end

    describe '#options_chain' do
      before do
        @getter = mock :getter
        @getter.stub(:get).with kind_of(String) do |url|
          if url =~ /m=\d{4}-\d{2}$/
            File.read 'spec/fixtures/options_chain_2.html'
          else
            File.read 'spec/fixtures/options_chain_1.html'
          end
        end
        @scraper = YahooFinance::Scraper::Company.new 'yhoo', getter: @getter
      end

      it 'should get options chain' do
        @scraper.options_chain.map(&:values).flatten.should be_all do |h|
          h.keys.sort == [ :ask, :bid, :change, :expires_at, :last, :open_int, :strike, :volume ]
        end
      end
    end
  end

  describe YahooFinance::Scraper::Actives do
    describe'.new' do
      before do
        @scraper = YahooFinance::Scraper::Actives.new
      end

      it 'should use custom http getter' do
        @scraper.getter.should == Net::HTTP
      end
    end

    describe '#losers' do
      before do
        @getter = mock :getter
        @getter.stub(:get).with kind_of(String) do |url|
          case url
          when /e=us/
            File.read 'spec/fixtures/losers_1.html'
          when /e=o/
            File.read 'spec/fixtures/losers_2.html'
          when /e=aq/
            File.read 'spec/fixtures/losers_3.html'
          when /e=nq/
            File.read 'spec/fixtures/losers_4.html'
          end
        end
        @scraper = YahooFinance::Scraper::Actives.new getter: @getter
      end

      it 'should get losers' do
        @scraper.losers.should be_all {|h| h.keys == [:symbol, :name] }
      end
    end
  end
end
