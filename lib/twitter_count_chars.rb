# -*- coding: utf-8 -*-
require 'active_support'
require 'active_support/core_ext/file'
require 'tmpdir'
require 'httpclient'
require 'json'

module TwitterCountChars
  module_function

  CONFIG_UPDATE_INTERVAL = 60 * 60 * 24

  def twitter_config_cache
    File.expand_path('~/.twitter_count_chars_config')
  end

  def update_twitter_config(force = false)
    if force ||
        !File.exist?(twitter_config_cache) || 
        File.mtime(twitter_config_cache) + CONFIG_UPDATE_INTERVAL + rand(100) <= Time.now
      client = HTTPClient.new
      r = client.get('http://api.twitter.com/1/help/configuration.json')
      if r.status == 200
        data = JSON.parse(r.body)
        cache = Hash[data.select{|k,v|["short_url_length", "short_url_length_https"].include?(k)}]
        File.atomic_write(twitter_config_cache) do |f|
          f << cache.to_json
        end
      else
        if force || !File.exist?(twitter_config_cache)
          raise "failed to get twitter config: #{r.inspect}"
        end
      end
    end
  end

  def twitter_config
    update_twitter_config
    open(twitter_config_cache){|f|JSON.parse(f.read)}
  end

  def short_url_length
    #twitter_config["short_url_length"]
    22
  end

  def short_url_length_https
    #twitter_config["short_url_length_https"]
    23
  end

  def length(text)
    # code from https://dev.twitter.com/docs/counting-characters
    text = ActiveSupport::Multibyte::Chars.new(text).normalize(:c).to_s
    # this pattern is not perfect!
    text = text.gsub(%r{(^|[^0-9A-Za-z_])http(s?)://[^\s/]+(/[\#\$\%\+,\-\./0-9\:;=@A-~\&À-ÿ]*)?}){|s|
      $1 + 'T' * ($2 == 's' ? short_url_length_https : short_url_length)
    }
    ActiveSupport::Multibyte::Chars.new(text).length
  end
end
