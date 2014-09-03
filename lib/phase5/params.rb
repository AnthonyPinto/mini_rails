require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    def initialize(req, route_params = {})
      @params = {}
      @params.merge! parse_www_encoded_form(req.query_string) if req.query_string
      @params.merge! parse_www_encoded_form(req.body) if req.body
      @params.merge! route_params if route_params
    end

    def [](key)
      @params[key.to_s]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      top_layer = URI::decode_www_form(www_encoded_form)
      parse_nested(top_layer)
    end
    
    def parse_nested(top_layer)
      
      # sub_hashes = top_layer.map do |keys_string, val|
      #   keys =  keys_string.split(/\]\[|\[|\]/)
      #   keys.reverse.inject(val) do |hash, next_key|
      #     {next_key => hash}
      #   end
      # end
      # sub_hashes.inject {|result, sub| result.merge(sub)}
      
      result_hash = {}
      
      sub_hashes = top_layer.map do |keys_string, val|
        keys =  keys_string.split(/\]\[|\[|\]/)
        current_hash = result_hash
        keys.each_with_index do |key, i|
          if i == (keys.length - 1)
            current_hash[key] = val
          else
            current_hash[key] ||= {}
            current_hash = current_hash[key]
          end
        end
      end
      
      result_hash
  
    end
    
    
        
    def hash_helper keys, val
      
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
    end
  end
end
