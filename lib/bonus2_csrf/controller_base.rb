require_relative '../bonus1_flash/controller_base'
require_relative './csrf'


module BonusCSRF
  class ControllerBase < BonusFlash::ControllerBase
    

    def initialize(req, res, route_params = {})
      super
      authenticate_request
      session["authenticity_token"] = SecureRandom.urlsafe_base64
    end
    
    def invoke_action(name)
      self.send(name)
      render(name) unless @already_built_response
    end

    
    def authenticate_request
      p @params["authenticity_token"]
      p session["authenticity_token"]
      if @req.request_method != 'GET' && @params["authenticity_token"] != session["authenticity_token"]
        raise "bingo bango non authenticated #{@req.request_method} request"
      end
    end
    
  end
end
