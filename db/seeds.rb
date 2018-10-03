require 'rest-client'
#api link: https://www.eia.gov/opendata/qb.php?category=1039863
api_key = 'ebd1dbc8bf695423c209d37473578b0d'

series_id_list = ['STEO.ESRCU_HAK.Q', 'STEO.ESRCU_ENC.Q', 'STEO.ESRCU_ESC.Q', 'STEO.ESRCU_MAC.Q', 'STEO.ESRCU_MTN.Q', 'STEO.ESRCU_NEC.Q', 'STEO.ESRCU_PAC.Q', 'STEO.ESRCU_SAC.Q', 'STEO.ESRCU_WNC.Q', 'STEO.ESRCU_WSC.Q']

def create_api_address(series_id, api_key)
  'http://api.eia.gov/series/?api_key=' + api_key + '&series_id=' + series_id
end

def send_request(url)
  response_string = RestClient.get(url)
  response_hash = JSON.parse(response_string)
end

def get_data_from_api(api_address)
  send_request(api_address)
end

def create_region_instance(return_hash)
  Region.find_or_create_by(:name => return_hash["series"][0]["geography"])
end

def create_period_instance(return_hash, instance_id)
  return_hash["series"][0]["data"].each do |period_price_array|
    Period.find_or_create_by(:name => period_price_array[0], :price => period_price_array[1].to_f, :region_id => instance_id)
  end
end

def get_region_id(instance)
  instance.id
end

def save_apis_to_database(series_id_list, api_key)
  series_id_list.each do |series_id|
    api_address = create_api_address(series_id, api_key)
    return_hash = get_data_from_api(api_address)
    region_instance = create_region_instance(return_hash)
    instance_id = get_region_id(instance)
    period_instance = create_period_instance(return_hash, instance_id)
    region_instance.periods << period_instance
  end
end

save_apis_to_database(series_id_list, api_key)
