class ResultController < ApplicationController
  def index
    ret = Array.new
    ret << 'apple_site.png'
    ret << 'www.apple.com'
    ret << 'apple_dev.png'
    ret << 'developer.apple.com'
    ret << 'ibooks.png'
    ret << 'www.apple.com/ibooks-author/'

    respond_to do |format|
      format.json { render :json => ret }
    end
  end
  
end
