require File.dirname(__FILE__) + '/spec_helper.rb'

describe :Phash do
  include SpecHelpers

  shared_examples :similarity do
    it "should return valid similarities" do
      collection.combination(2) do |a, b|
        if main_name(a.path) == main_name(b.path)
          (a % b).should > 0.8
        else
          (a % b).should <= 0.5
        end
      end
    end

    it "should return same similarity if swapping instances" do
      collection.combination(2) do |a, b|
        (a % b).should == (b % a)
      end
    end
  end

#  describe :Audio do
#    let(:collection){ Phash::Audio.for_paths filenames('*.mp3') }
#    include_examples :similarity
#  end

  describe :Image do
    let(:collection){ Phash::Image.for_paths filenames('**/*.{jpg,png}') }
    include_examples :similarity
  end

#  describe :Text do
#    let(:collection){ Phash::Text.for_paths filenames('*.txt') }
#    include_examples :similarity
#  end

#  describe :Video do
#    let(:collection){ Phash::Video.for_paths filenames('*.mp4') }
#    include_examples :similarity
#  end

  describe "raw hashes calculations" do
    require 'phash/image'

    it 'should calculate DCT-based image hash by default' do
      Phash.image_fingerprint(filenames('jug-0-10.jpg').first).should == "0111100110010011100101100001100101111001011000111000011010011100"
    end

    it 'should calculate MH-based image hash when requested' do
      proper_phash = "000000000000000000000000000000000010111111011000000000000000000000000000000000000000000000111110011100011111100100011111011011000000000000000000000000000001001001101001010100100000010110111000000100000000000000000000000000000110110111101011111100010010101100010100100011000000000000000000000000000000001001100100100111101000011011000110110110000000000000000000000000000001000000100100000000111111000110110110110110000000000000000000000000000111111010011111010001111100011000111011011111111111000000000100000000000011110111111011100111111000111001000111111000111000110100000000"
      Phash.image_fingerprint(filenames('jug-0-10.jpg').first, :mh).should == proper_phash
    end
  end
end
