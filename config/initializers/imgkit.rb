IMGKit.configure do |config|
  #config.wkhtmltoimage = '/usr/local/bin'
  config.default_options = {
    :quality => 100,
    :width => 630,
  }
  config.default_format = :jpg
end