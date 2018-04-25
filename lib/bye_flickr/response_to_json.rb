module ByeFlickr

  class ResponseToJson
    def initialize(r)
      @r = r
    end

    def self.call(r)
      new(r).serialize.to_json
    end

    def serialize(o = @r)
      case o
      when FlickRaw::Response
        serialize_response o
      when FlickRaw::ResponseList, Enumerable
        serialize_response_list o
      else
        o
      end
    end


    private

    def serialize_response_list(list)
      list.to_a.map{|o|serialize(o)}
    end

    def serialize_response(r)
      Hash.new.tap do |hsh|
        r.to_hash.each do |key, value|
          hsh[key] = serialize value
        end
      end
    end
  end

end
