# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TwitterCountChars" do
  TCC = TwitterCountChars
  it "should count length" do
    decomposed ="e\xCC\x81"
    TCC.length("cafe").should == 4
    TCC.length("caf#{decomposed}").should == 4
    TCC.stub!(:short_url_length).and_return(100)
    TCC.stub!(:short_url_length_https).and_return(101)
    TCC.length("cafe http://example.com/").should == 105
    TCC.length("https://example.com/cafécafeかふぇ").should == 104
    TCC.length("cafehttp://example.com/").should == "cafehttp://example.com/".size
    TCC.length("http://example.com/").should == 100
  end

#  it "should get short_url_length" do
#    TCC.short_url_length.should >= 19
#    TCC.short_url_length_https.should >= 20
#  end

#  it "should update config" do
#    TCC.update_twitter_config(true)
#    open(TCC.twitter_config_cache) do |f|
#      data = JSON.parse(f.read)
#      data["short_url_length"].should >= 19
#      data["short_url_length_https"].should >= 20
#    end
#  end
end
