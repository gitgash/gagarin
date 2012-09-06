require 'net/http'
require 'nokogiri'
require 'uri'
require 'imgkit'

class ResultController < ApplicationController
  def index
    
    
    #call server
    http_session = Net::HTTP.new('3d.sputnik.ru', 80)
    ret = http_session.start do |http| 
      req = Net::HTTP::Get.new("/search?q=#{URI.encode params[:search]}&xmlout=1")
      # req.basic_auth 'admin', 'SearchRF'
      req.basic_auth 'html5', 'KvorumSLA'
      response = http.request(req)
      doc  = Nokogiri::XML(response.body.to_s)
      
      #collect sections
      uri = URI(request.url)
      u = uri.to_s
      u['/result.json'] = ''
      u['http://'] = ''
      p "DEBUG+++++++++++++++++++++++++++++++++++++++++++++++++++++" + u
      
      h = {}
      doc.xpath('//query').each do |q|
        h[q['collection'].to_i] = [
          "#{result_section_path(:id => q['collection'])}.jpg?search=#{URI.encode params[:search]}",
          u + "#{result_section_path(:id => q['collection'])}.html?search=#{URI.encode params[:search]}"
        ]
      end

      # 16 - блоги
      # 17 - картинки         2 3
      # 18 - видео          1    4
      # 31 - Интернет         0
      # 2223 - новости
      [31, 2223, 16, 18, 17].inject([]) { |a, s| a + h[s] }
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
        @results << {
          :url => r.xpath('url'), 
          :title => r.xpath('title'), 
          :url_show => r.xpath('url_show'), 
          :title_show => r.xpath('title_show'), 
          :snippet => r.xpath('snippet'),
          :datetime => r.xpath('datetime'),
          :image_url =>
            # обязательно переделать эту хрень!!!
            if r.xpath('user_data').empty?
              nil
            elsif r.xpath('user_data').xpath('image_data').empty?
              if r.xpath('user_data').xpath('video_data').empty?
                nil
              else
                r.xpath('user_data').xpath('video_data').attribute('thumbnail')
              end
            else           
              r.xpath('user_data').xpath('image_data').attribute('url')
            end,
        }
      end
    end
    @section_code=params[:id]
    
    respond_to do |format|
      format.html
      format.jpg  {
        #let imgkit load html from current host and convert
        #write jpg out
        
        uri = URI(request.url)
        s = uri.path
        s['.jpg'] = '.html'
        uri.path = s
        uri.port = RENDERER_PORT
        contents = IMGKit.new(uri.to_s)
        send_data contents.to_img(:jpg), :filename => "#{params[:id]}.jpg", 
                                        :disposition => 'inline', 
                                        :type => "image/jpg"
      }
    end
  end
    
end
