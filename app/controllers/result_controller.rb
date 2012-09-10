# coding: utf-8

require 'net/http'
require 'nokogiri'
require 'uri'
require 'imgkit'
require 'dalli'

class ResultController < ApplicationController
  #before_filter :cach_cash
  caches_action :index, :section, :cache_path => Proc.new { |controller| controller.params }
  
  def index
    ret = nil
    
    #call server
    http_session = Net::HTTP.new('3d.sputnik.ru', 80)
    http_session.start do |http| 
      req = Net::HTTP::Get.new("/search?q=#{URI.encode params[:search]}&xmlout=1")
      # req.basic_auth 'admin', 'SearchRF'
      # req.basic_auth 'html5', 'KvorumSLA'
      req.basic_auth 'rtk', 'KapitanLTE'
      response = http.request(req)
      doc  = Nokogiri::XML(response.body.to_s)
      
      #collect sections
      uri = URI(request.url)
      u = uri.to_s
      u[/\/result\.json.*$/] = ''
      u['http://'] = ''

      unless doc.xpath('//query').blank?
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
        ret = [31, 2223, 16, 18, 17].inject([]) { |a, s| a + h[s] }
      else
        # самая простая костыльная реализация
        ret = [
          "/profanity.jpg", "#{u}/profanity.html",
          "/result/section/2223.jpg?search=xuyandzhopenotfound", "#{u}/result/section/2223.html?search=xuyandzhopenotfound",
          "/result/section/16.jpg?search=xuyandzhopenotfound", "#{u}/result/section/16.html?search=xuyandzhopenotfound",
          "/result/section/18.jpg?search=xuyandzhopenotfound", "#{u}/result/section/18.html?search=xuyandzhopenotfound",
          "/result/section/17.jpg?search=xuyandzhopenotfound", "#{u}/result/section/17.html?search=xuyandzhopenotfound",
        ]
      end
      
      #save this object for later use
      keys = URI::split(request.url)
      key="SPUTNIKQUERY/#{params[:search]}"
      v = Rails.cache.write(key, response.body.to_s, :timeToLive => 1.day)
      p "DEBUG========================================= write v=#{v} key=#{key}"
    end
    
    respond_to do |format|
      format.json { render :json => ret }
    end
  end
  
  def section
  
    respond_to do |format|
      format.html {
        #read saved sputnik responce
        keys = URI::split(request.url)
        key="SPUTNIKQUERY/#{params[:search]}"
        xml = Rails.cache.read(key)
        p "DEBUG================================= key = #{key} xml nil?#{xml==nil}"
        
        doc  = Nokogiri::XML(xml)

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
        @section_code = params[:id]
        
        render
      }
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
  
  # protected
  # def cach_cash
  #   keys = URI::split(request.url)
  #   p "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++DEBUG keys[5]="+keys[5] if keys[5] != nil
  #   p "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++DEBUG keys[7]="+keys[7] if keys[7] != nil
  #   p "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++DEBUG key="+"#{keys[5]}/#{keys[7]}"
  # end
    
end
