# coding: UTF-8
config_hash = YAML.load_file("#{Rails.root}/config/gagarin.yml")[Rails.env]
RENDERER_PORT = config_hash['renderer']['port']
