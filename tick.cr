#!/usr/bin/env crystal

require "json"
require "http/client"
require "option_parser"

module Tick
  VERSION = "0.1.2"
  API_ENDPOINT = "https://query1.finance.yahoo.com/v7/finance/quote?lang=en-US&region=US&corsDomain=finance.yahoo.com"
  COLOR_GREEN = "\e[32m"
  COLOR_RED = "\e[31m"
  COLOR_RESET = "\e[00m"
  OPTS = {"include" => false, "regular" => false}

  alias PadCounts = NamedTuple(symbol: Int32, price: Int32, change: Int32, pct: Int32)

  class HttpResponse
    include JSON::Serializable

    @[JSON::Field(key: "quoteResponse")]
    getter quote_response : QuoteResponse
  end

  class QuoteResponse
    include JSON::Serializable

    @[JSON::Field(key: "result")]
    getter results : Array(QuoteResult)
  end

  class QuoteResult
    include JSON::Serializable

    getter symbol : String

    @[JSON::Field(key: "marketState")]
    getter market_state : String

    @[JSON::Field(key: "regularMarketPrice")]
    getter regular_market_price : Float64?

    @[JSON::Field(key: "regularMarketChange")]
    getter regular_market_change : Float64?

    @[JSON::Field(key: "regularMarketChangePercent")]
    getter regular_market_change_percent : Float64?

    @[JSON::Field(key: "preMarketPrice")]
    getter pre_market_price : Float64?

    @[JSON::Field(key: "preMarketChange")]
    getter pre_market_change : Float64?

    @[JSON::Field(key: "preMarketChangePercent")]
    getter pre_market_change_percent : Float64?

    @[JSON::Field(key: "postMarketPrice")]
    getter post_market_price : Float64?

    @[JSON::Field(key: "postMarketChange")]
    getter post_market_change : Float64?

    @[JSON::Field(key: "postMarketChangePercent")]
    getter post_market_change_percent : Float64?

    def ignore?
      regular_market_price.nil?
    end

    def non_regular_market_sign
      OPTS["regular"] || market_state == "REGULAR" ? "" : "*"
    end

    def price
      if market_state == "REGULAR" || OPTS["regular"]
        regular_market_price.not_nil!
      elsif market_state == "PRE"
        pre_market_price.not_nil!
      else
        post_market_price.not_nil!
      end
    end

    def change
      if market_state == "REGULAR" || OPTS["regular"]
        regular_market_change.not_nil!
      elsif market_state == "PRE"
        pre_market_change.not_nil!
      else
        post_market_change.not_nil!
      end
    end

    def percent
      if market_state == "REGULAR" || OPTS["regular"]
        regular_market_change_percent.not_nil!
      elsif market_state == "PRE"
        pre_market_change_percent.not_nil!
      else
        post_market_change_percent.not_nil!
      end
    end
  end

  def self.fetch(symbols : Array(String))
    response = HTTP::Client.get(
      "#{API_ENDPOINT}&symbols=#{symbols.join(",")}"
    )
    HttpResponse.from_json(response.body)
  end

  def self.pad(str_input : String | Float64, size : Int32, align_left = false)
    str = str_input.to_s
    padding_size = [size - str.size, 0].max
    padding = " " * padding_size
    align_left ? "#{str}#{padding}" : "#{padding}#{str}"
  end

  def self.print_result(result : QuoteResult, cols : PadCounts)
    puts "#{pad(result.symbol, cols[:symbol], true)}  " +
         "#{pad(result.price.format(".", "", decimal_places: 2), cols[:price])}  " +
         "#{colorized(result.change, cols[:change])}  " +
         "#{colorized(result.percent, cols[:pct], true)} " +
         "#{result.non_regular_market_sign}"
  end

  def self.get_cols(results : Array(QuoteResult)) : PadCounts
    {
      symbol: results.map(&.symbol.size).max,
      price: results.map { |r| r.price.format(".", "", decimal_places: 2).size }.max,
      change: results.map { |r| r.change.format(".", "", decimal_places: 2).size }.max,
      pct: results.map { |r| r.percent.format(".", "", decimal_places: 2).size + 3 }.max
    }
  end

  def self.colorized(num : Float64, padding_size : Int32, pct = false)
    num_str = "#{pct ? "(" : ""}#{num.format(".", "", decimal_places: 2)}#{pct ? "%)" : ""}"
    num_str = pad(num_str, padding_size)
    if ENV["NO_COLOR"]?
      num_str
    elsif num < 0
      "#{COLOR_RED}#{num_str}#{COLOR_RESET}"
    elsif num > 0
      "#{COLOR_GREEN}#{num_str}#{COLOR_RESET}"
    else
      num_str
    end
  end

  def self.parse_symbols
    parser = OptionParser.parse(ARGV) do |parser|
      parser.banner = "Usage: tick [symbol, ...]\nGet stock prices and changes"
      parser.on("-h", "--help", "print this help message") { puts(parser); exit }
      parser.on("-v", "--version", "print version") { puts(VERSION); exit }
      parser.on("-i", "--include", "include additional symbols") { OPTS["include"] = true }
      parser.on("-r", "--regular", "regular market hours only") { OPTS["regular"] = true }
    end

    symbols = Array(String).new
    if ARGV.empty? && ENV["TICK"]?
      symbols = ENV["TICK"].split(" ")
    elsif OPTS["include"] && ENV["TICK"]?
      symbols = ENV["TICK"].split(" ") + ARGV
    else
      symbols = ARGV
    end

    if symbols.empty?
      puts parser
      exit
    end
    symbols.map(&.upcase)
  end

  def self.run
    symbols = parse_symbols
    results = Hash(String, QuoteResult).new
    fetch(symbols).quote_response.results.each do |result|
      results[result.symbol] = result unless result.ignore?
    end
    return if results.empty?

    cols = get_cols(results.values)
    symbols.each do |symbol|
      print_result(results[symbol], cols) if results.has_key?(symbol)
    end
  end
end

Tick.run
