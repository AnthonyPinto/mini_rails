require 'webrick'
require 'bonus1_flash/flash'
require 'bonus1_flash/controller_base'

describe BonusFlash::Flash do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cook) { WEBrick::Cookie.new('_rails_lite_flash', { xyz: 'abc' }.to_json) }

  it "deserializes json cookie if one exists" do
    req.cookies << cook
    flash = BonusFlash::Flash.new(req)
    flash['xyz'].should == 'abc'
  end

  describe "#store_flash" do
    context "without cookies in request" do
      before(:each) do
        flash = BonusFlash::Flash.new(req)
        flash['first_key'] = 'first_val'
        flash.store_flash(res)
      end

      it "adds new cookie with '_rails_lite_flash' name to response" do
        cookie = res.cookies.find { |c| c.name == '_rails_lite_flash' }
        cookie.should_not be_nil
      end

      it "stores the cookie in json format" do
        cookie = res.cookies.find { |c| c.name == '_rails_lite_flash' }
        JSON.parse(cookie.value).should be_instance_of(Hash)
      end
    end

    context "with cookies in request" do
      before(:each) do
        cook = WEBrick::Cookie.new('_rails_lite_flash', { pho: "soup" }.to_json)
        req.cookies << cook
      end

      it "reads the pre-existing and 'flash.now' cookie data into hash" do
        flash = BonusFlash::Flash.new(req)
        flash.now['waffle'] = 'belgian'

        flash['pho'].should == 'soup'
        flash['waffle'].should == 'belgian'
      end
      
      it "cookie data saved to flash.now is not accessable after redirect" do
        flash = BonusFlash::Flash.new(req)
        flash.now['waffle'] = 'belgian'
        flash.store_flash(res)
        cookie = res.cookies.find { |c| c.name == '_rails_lite_flash' }
        h = JSON.parse(cookie.value)
        h['waffle'].should == nil
      end
      

      it "cookie data saved to flash is not accessable after second redirect" do
        flash = BonusFlash::Flash.new(req)
        flash['machine'] = 'mocha'
        flash.store_flash(res)
        cookie = res.cookies.find { |c| c.name == '_rails_lite_flash' }
        h = JSON.parse(cookie.value)
        h['pho'].should == nil
        h['machine'].should == 'mocha'
      end
    end
  end
end

describe BonusFlash::ControllerBase do
  before(:all) do
    class CatsController < BonusFlash::ControllerBase
    end
  end
  after(:all) { Object.send(:remove_const, "CatsController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cats_controller) { CatsController.new(req, res) }

  describe "#flash" do
    it "returns a flash instance" do
      expect(cats_controller.flash).to be_a(BonusFlash::Flash)
    end

    it "returns the same instance on successive invocations" do
      first_result = cats_controller.flash
      expect(cats_controller.flash).to be(first_result)
    end
    
    it "should store flash data in the object" do
      cats_controller.flash['test_key'] = 'test_value'
      cats_controller.flash['test_key'].should == 'test_value'
    end
    
    it "should store flash.now data in the object" do
      cats_controller.flash.now['now_key'] = 'now_value'
      cats_controller.flash.now['now_key'].should == 'now_value'
    end
  end
  

  shared_examples_for "passing flash data to cookie" do
    it "should pass the flash data to cookie (not flash.now)" do
      cats_controller.flash['test_key'] = 'test_value'
      cats_controller.flash.now['now_key'] = 'now_value'
      cats_controller.send(method, *args)
      cookie = res.cookies.find { |c| c.name == '_rails_lite_flash' }
      h = JSON.parse(cookie.value)
      expect(h['test_key']).to eq('test_value')
      expect(h['now_key']).to eq(nil)
    end
  end

  describe "#redirect_to" do
    let(:method) { :redirect_to }
    let(:args) { ['http://appacademy.io'] }
    include_examples "passing flash data to cookie"
  end
end
