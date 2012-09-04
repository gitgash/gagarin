require 'net/http'
require 'nokogiri'
require 'uri'
require 'imgkit'

class ResultController < ApplicationController
  def index
    
    
    ret = Array.new
    #call server
    http_session = Net::HTTP.new('3d.sputnik.ru', 80)
    http_session.start do |http| 
      req = Net::HTTP::Get.new("/search?q=#{URI.encode params[:search]}&xmlout=1")
      # req.basic_auth 'admin', 'SearchRF'
      req.basic_auth 'html5', 'KvorumSLA'
      response = http.request(req)
      doc  = Nokogiri::XML(response.body.to_s)
      
      #collect sections
      doc.xpath('//query').each do |q|
        ret << "#{result_section_path(:id => q['collection'])}.jpg?search=#{URI.encode params[:search]}"
        ret << "#{result_section_path(:id => q['collection'])}.html?search=#{URI.encode params[:search]}"
      end

    end
    
    respond_to do |format|
      format.json { render :json => ret }
    end
  end
  
  def section
    http_session = Net::HTTP.new('3d.sputnik.ru', 80)
    http_session.start do |http| 
      req = Net::HTTP::Get.new("/search?q=#{URI.encode params[:search]}&xmlout=1")
      # req.basic_auth 'admin', 'SearchRF'
      req.basic_auth 'html5', 'KvorumSLA'
      response = http.request(req)
      doc  = Nokogiri::XML(response.body.to_s)
      
      #get section
      sec = doc.xpath("//kmsearch[query[@collection=#{params[:id]}]]")
      
      @results = Array.new
      sec.xpath("result").each do |r|
        @results << {:url => r.xpath('url'), :title => r.xpath('title'), :url_show => r.xpath('url_show'), :title_show => r.xpath('title_show')}
      end
    end
    
    respond_to do |format|
      format.html
      format.jpg  {
        #let imgkit load html from current host and convert
        #write jpg out
        
        p "DEBUGG>>> request.url="+request.url
        uri = URI(request.url)
        s = uri.path
        p "DEBUGG>>> s="+s
        s['.jpg'] = '.html'
        uri.path = s
        uri.port = 3003
        p "DEBUGG>>> uri="+uri.to_s
        contents = IMGKit.new(uri.to_s)
        #contents = IMGKit.new("http://www.google.com")
        #File.open("img.jpg", 'w') {|f| f.write(contents.to_img(:jpg)) }
        send_data contents.to_img(:jpg), :filename => "#{params[:id]}.jpg", 
                                        :disposition => 'inline', 
                                        :type => "image/jpg"
      }
    end
  end
    
end
