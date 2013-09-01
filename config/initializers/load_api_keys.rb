# Loads api config from ROOT/config/api_keys.yml

module LoadApiKeys
  api_key_set = YAML::load_file(File.join(__dir__, '..', 'api_keys.yml'))
  if Rails.env.production?
    $api_keys = api_key_set["production"]
  else
    $api_keys = api_key_set["development"]
  end
end
