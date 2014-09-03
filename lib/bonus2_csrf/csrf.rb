require 'json'
require 'webrick'

module BonusFlash
  class Flash
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      cookie = req.cookies.find {|cookie| cookie.name == '_rails_lite_flash'}
      @now_value = cookie ? JSON.parse(cookie.value) : {}
      @next_value = {}
    end
    
    def now
      @now_value
    end

    def [](key)
      @now_value[key]
    end

    def []=(key, val)
      @now_value[key] = val
      @next_value[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_flash(res)
      cookie = WEBrick::Cookie.new(
        '_rails_lite_flash',
        JSON.generate(@next_value)
        )
        
      res.cookies << cookie

    end
  end
end
