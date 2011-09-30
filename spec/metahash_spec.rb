require 'metahash'
require 'ruby-debug'
module Metahash
  describe Metahash do
    before {
      @test_path = File.dirname(__FILE__)+"/test.txt"  
      @test_data = {"hello"=>"world"}
    }

    context "generally" do #high level expectations

      it "should be able to append to a new file" do
        
        mh = Metahash.new @test_path
        mh.write({"hello"=>"world"})

        mh = Metahash.new @test_path
        obj = mh.to_h
        obj.should be_a(Hash)
        obj["hello"].should == "world"

      end
      it "should be able to modify an already tagged file" do
        mh = Metahash.new @test_path 
        mh.write({"hello"=>"world"})

        mh = Metahash.new @test_path
        mh.write({"hello"=>"holmes"})

        mh = Metahash.new @test_path
        obj = mh.to_h
        obj.should be_a(Hash)
        obj["hello"].should == "holmes"
      end
    end
    describe "specifically" do
      let(:new_metahash_with_untagged_file) do
        f = File.open @test_path,"w+"
        f.write "Hello World"
        f.close
        Metahash.new @test_path 
      end
      let(:new_metahash_with_tagged_file) do
        mh = new_metahash_with_untagged_file
        mh.write @test_data
        mh
      end
      
      describe "#initialize" do
        it "should throw an error on an invalid path" do
          invalid_path = rand().to_s+@test_path
          expect{
            mh = Metahash.new invalid_path
          }.to raise_error(ArgumentError)
        end
        it "should not throw an error on a valid path" do
          lambda {
           new_metahash_with_untagged_file
          }.should_not raise_error(ArgumentError)
        end
      end
      describe "#tagged?" do
        it "should return false for untagged files" do
          new_metahash_with_untagged_file.should_not be_tagged
        end
        it "should return true for tagged files" do
          new_metahash_with_tagged_file.should be_tagged
        end
      end
      describe "#write" do
        context "with an untagged file" do
          subject &:new_metahash_with_untagged_file 
          it "should call wrap obj and serialize" do
            subject.should_receive(:wrap_obj).with(@test_data)
            BSON.should_receive :serialize
            subject.write @test_data
          end
          it "should call initialize after write" do
            subject.should_receive(:initialize).exactly(1).times 
            subject.write @test_data
          end
        end
        context "with a tagged file" do
          subject &:new_metahash_with_tagged_file
          it "should truncate already tagged file" do
            File.should_receive(:truncate).with(@test_path,0)
            subject.write({"hello"=>"holmes"})
          end
        end
      end
      describe "#to_h" do
        context "with an untagged file" do
          subject &:new_metahash_with_untagged_file 
          it "should return nil" do
            subject.to_h.should be_nil
          end
        end
        context "with a tagged file" do
          subject &:new_metahash_with_tagged_file
          it "should return test data" do
            subject.to_h.should == @test_data
          end
        end
      end
      describe "#method_missing" do
        context "with a tagged file" do
          subject &:new_metahash_with_tagged_file
          it "should read just like a hash" do
            subject["hello"].should == "world" 
          end
          it "should write and persist" do
            #debugger
            subject["foo"] = "bar"
            subject["foo"].should == "bar"
          end
        end
        context "with an untagged file" do
          subject &:new_metahash_with_untagged_file
          it "should just work" do
            subject["artist"] = "dave matthews"

            mh = Metahash.new @test_path
            mh["artist"].should == "dave matthews"
          end
        end


      end
    end

  end
end
