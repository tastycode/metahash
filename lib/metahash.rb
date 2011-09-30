require 'metahash/version'
require 'rubygems'
require 'bson'
require 'json'
module Metahash
  class Metahash
    BOM = (JSON '["\uFEFF"]')[0]
    SEARCH_BYTE_OFFSET = 4
    SEARCH_BYTE_SEQUENCE = "\003bson-\357\273\277"
    def initialize(path,options={})
      raise ArgumentError unless File.exists? path
      @path     = path
      @options  = options
      bson      = read_for_search  File.open(@path,"rb") 
      if bson
        @bson_range = bson[:range]
        @bson_size  = bson[:size]
        @bytes      = bson[:bytes]
      end
      self
    end
    # returns current state of metahash, false if no tag attahed, true if tag attached
    def tagged?
      !@bson_size.nil?
    end

    # returns a hash 
    def to_h
      return nil if @bytes.nil?
      packet = BSON.deserialize(BSON::ByteBuffer.new(@bytes[@bson_range])) 
      packet["bson-#{BOM}"]["object"]
    end

    # allow transparent usage like hash
    # TODO: This is ridiculous, truly a monkey patch to provide cool functionality, please implement hash correctly
    def method_missing(method,*args)
      if {}.respond_to?(method) 
        hash = to_h||{}
        result = hash.send(method,*args)
        write hash
        result
      else
        super
      end
    end
    def write(obj)
      byte_string = BSON.serialize(wrap_obj(obj)).to_s
      if @bytes
        #take 0..bson_start 
        #serialize object
        #with bson_end..-1
        @bytes=@bytes[0..@bson_range.first]+byte_string+@bytes[@bson_range.last..-1]
        #write and reinitialize 
        File.truncate(@path,0)
        File.open(@path,"wb+") do |file|
          file.write(@bytes)
        end
      else
        File.open(@path,"ab+") do |file|
          file.write(byte_string)
        end
      end
      initialize(@path,@options)
    end
    private

    # wraps obj in Meta Hash header
    def wrap_obj(obj)
      meta_bson = {
        "bson-#{BOM}"=>{
          "version"=>VERSION,
          "ns"=>["http://json-schema.org/card.properties","http://groups.google.com/group/json-schema/browse_thread/thread/dd1a8c9e55035c67?pli=1"],
          "object"=> obj
        }
      }
    end
    def read_for_search(io)
      bytes = io.read
      search_position = bytes.index(SEARCH_BYTE_SEQUENCE)
      return nil unless search_position
      bson_start = search_position - SEARCH_BYTE_OFFSET
      bson_size = bytes[bson_start..(search_position-1)].unpack("S")[0]
      bson_end = bson_start + bson_size
      return {
          :range =>  bson_start..bson_end,
          :size  =>  bson_size,
          :bytes =>  bytes
      }
    end
  end
end
