# -*- coding: utf-8 -*-
require 'sinatra'
require 'net/http'
require 'rexml/document'
require 'open-uri'
require 'cgi'
require 'json'

def maybe(message)
  if message['text'] !~ /^もしかして[. :：]*(.+)$/ 
    return ""
  end
  word = $1
  ret = ''
  open("http://www.google.co.jp/complete/search?ie=utf8&oe=utf-8&output=toolbar&q=#{CGI::escape(word)}") do |f|
    doc = REXML::Document.new f
    doc.elements.each("//toplevel/CompleteSuggestion/suggestion") do |elem|
      ret += "#{elem.attributes["data"]}\n"
    end
  end
  ret
end

post '/lingr' do
  json = JSON.parse(request.body.string)
  json["events"].
    map {|e| e['message'] }.
    compact.
    map {|x| "#{maybe(x)}" }.
    join.
    rstrip[0..999]
end
