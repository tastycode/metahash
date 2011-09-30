Metahash
========

Yet another extensible metadata platform, this should replace EXIF and ID3. For background see http://seal-7.blogspot.com/

Usage
-----

    require 'metahash'

    # Writing to a file
    mh = Metahash::Metahash.new "path/to/beiber.mp3"
    mh["id3:artist"] = "Bob Dylan"
    mh["id3:title"]  = "Casey Jones"
    # We can make this as complex as we would like
    mh["genres"]     = ["punk","neo-post-contemporary bluegrass"]
    mh["album"]      = {
        :title => "Dark side of the moon",
        :year  => 2002
    }

    # Reading 
    mh = Metahash::Metahash.new "path/to/beiber.mp3"
    mh.to_h 
    # All hash methods apply to Metahash
    mh.keys


Specification
-------------

Metahash allows an aritrary data of any structure to be stored in any file that would not become corrupted
by adding additional bytes onto the end of the file. Files that include checksums and size checks usually do not
fit this category. 

Metahash is stored as BSON in a special wrapper. The wrapper is structured as such.

    meta_bson = {
      "bson-\uFEFF"=>{
        "version"=>VERSION,
        "ns"=>[],
        "object"=> obj
      }
    }

Where \uFEFF is unicode \u+FEFF which is a byte order marker intended to help locate the wrapper within a file.
obj can be any obj of any structure so long as the BSON specification can accomodate its size. 
The BSON specification provides a 32 bit integer to store the size. The maximum size is currently 4095 MB.
