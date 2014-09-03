require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      cookie = req.cookies.find {|cookie| cookie.name == '_rails_lite_app'}
      @cookie_value = cookie ? JSON.parse(cookie.value) : {}
    end

    def [](key)
      @cookie_value[key]
    end

    def []=(key, val)
      @cookie_value[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      cookie = WEBrick::Cookie.new(
        '_rails_lite_app',
        JSON.generate(@cookie_value)
        )
        
      res.cookies << cookie

    end
  end
end
