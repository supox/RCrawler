#!/usr/bin/env ruby
require_relative './rap_data_crawler' 
require_relative './rap_tasker' 

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do 
  $running = false
end

Rails.logger.info "RapDeamon - starting."
tasker = RapTasker.new
crawler = RapDataCrawler.new

while($running) do
  Rails.logger.info "RapDeamon - looping."

  while (t = tasker.next) and $running
    begin
    crawler.crawl t
    rescue => e
      Rails.logger.info "Crawler error: #{e}"
      sleep 10.seconds
    end
  end

  crawler.close

  Rails.logger.info "RapDeamon - sleeping."
  sleep 1.hour if $running
end
puts "Done."
