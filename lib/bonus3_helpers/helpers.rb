require 'json'
require 'webrick'
require 'active_support/inflector'

module BonusHelpers
  class URLHelper
    
    def initialize(pattern, controller_class, action_name)
      @pattern, @controller_class, @action_name = pattern, controller_class, action_name
    end
    
    
    def build_html(*ids)
      url_parts = strip_words
      insert_ids(url_parts, ids)
    end
    
    def strip_words
      url_parts = @pattern.to_s.downcase[8...-2].split('/')
      url_parts.map! do |str| 
        if ('a'..'z').include? str[0] 
          (/\w+/).match(str).to_s
        else
          nil
        end  
      end
      url_parts.compact
    end
    
    def insert_ids(url_parts, ids)
      string = ''
      url_parts.each_with_index do |part, i|
        string = string + '/' + part
        string = string + '/' + ids[i].to_s if ids[i]
      end
      string
    end
  
  end
end
