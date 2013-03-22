require 'phash'

module Phash
  # compute dct robust image hash
  #
  # param file string variable for name of file
  # param hash of type ulong64 (must be 64-bit variable)
  # return int value - -1 for failure, 1 for success
  #
  # int ph_dct_imagehash(const char* file, ulong64 &hash);
  #
  attach_function :ph_dct_imagehash, [:string, :pointer], :int, :blocking => true

  # int ph_mh_imagehash(const char* file, int &len);
  attach_function :ph_mh_imagehash2, [:string, :pointer], :int, :blocking => true

  # no info in pHash.h
  #
  # int ph_hamming_distance(const ulong64 hash1,const ulong64 hash2);
  #
  attach_function :ph_hamming_distance, [:uint64, :uint64], :int, :blocking => true

  class << self
    # Get image file hash using <tt>ph_dct_imagehash</tt>
    def image_hash(path, options = {})
      hash_p = FFI::MemoryPointer.new :ulong_long
      if -1 != ph_dct_imagehash(path.to_s, hash_p)
        hash = hash_p.get_uint64(0)
        ImageHash.new(hash)
      end
    end

    def mh_image_hash(path)
      hash_p = FFI::MemoryPointer.new :uint8, 72

      ph_mh_imagehash2(path.to_s, hash_p)

      if hash_p != nil
        arr = hash_p.get_array_of_uint8(0, 72)
        arr
      end
    end

    def image_fingerprint(path, type = :pct)
      if type == :pct
        val = image_hash(path).data
        str = val.to_s(2)
        "#{'0' * (64 - str.length)}#{str}"
      else
        mh_image_hash(path).map {|i|
          str = i.to_s(2)
          "#{'0' * (8 - str.length)}#{str}"
        }.join('')
      end
    end

    # Get distance between two image hashes using <tt>ph_hamming_distance</tt>
    def image_hamming_distance(hash_a, hash_b)
      hash_a.is_a?(ImageHash) or raise ArgumentError.new('hash_a is not an ImageHash')
      hash_b.is_a?(ImageHash) or raise ArgumentError.new('hash_b is not an ImageHash')

      ph_hamming_distance(hash_a.data, hash_b.data)
    end

    # Get similarity from hamming_distance
    def image_similarity(hash_a, hash_b)
      1 - image_hamming_distance(hash_a, hash_b) / 64.0
    end
  end

  # Class to store image hash and compare to other
  class ImageHash < HashData
  end

  # Class to store image file hash and compare to other
  class Image < FileHash
  end
end
