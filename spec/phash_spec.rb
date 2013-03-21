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

  describe :Audio do
    let(:collection){ Phash::Audio.for_paths filenames('*.mp3') }
    include_examples :similarity
  end

  describe :Image do
    let(:collection){ Phash::Image.for_paths filenames('**/*.{jpg,png}') }
    include_examples :similarity
  end

  describe :Text do
    let(:collection){ Phash::Text.for_paths filenames('*.txt') }
    include_examples :similarity
  end

  describe :Video do
    let(:collection){ Phash::Video.for_paths filenames('*.mp4') }
    include_examples :similarity
  end

  describe "raw hashes calculations" do
    require 'phash/image'

    it 'should calculate DCT-based image hash by default' do
      Phash.image_fingerprint(filenames('jug-0-10.jpg').first).should == "0111100110010011100101100001100101111001011000111000011010011100"
    end

    it 'should calculate MH-based image hash when requested' do
      Phash.image_fingerprint(filenames('jug-0-10.jpg').first, :mh).should == "000000000000000000000000000000000010111111011000000000000000000000000000000000000000000000111110011110011111100100011111011111000000000000000000000000000001001001101010010100100000010010111000000100000000000000000000000000000110110111101011111100010010101100010100100011000000000000000000000000000000000000100100100110111000011011000010010010000000000000000000000000000000000000100100000000111111000110111010110101000000000000000000000000000111111010011111010001111100010010101011011111000011000000000000000000000011110111101011110011000000110000010111110010001001110000000000"
    end
  end
end
