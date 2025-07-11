require_relative '../lib/netenos'

# Tests if stimulus are written in the right order when using the binary format


# Methods to be tested :
# - AtetaAddOn::Ateta.save_explicit
 
# Test procedure :
# Prepare a text vector (or a few) wih is not symetrical (001 is OK, 101 is NOT OK)
# Save it with the method to be tested
# Reaf the file and compare with the expected. 
# The bits are supposed to be written in the same order as in the ruby array. That is to say the bit that is at the far most left should correspond to the index 0 in the ruby array, the far most right should correspond to the greatest index in the ruby array :
# Index in ruby array     : 0    1    2
# Value in ruby array     : 0    0    1
# Value in file (ordered) : 0    0    1

class TestAteta < AtetaAddOn::Ateta
  attr_accessor :solutions  

  def initialize
    
  end

  def save_explicit_add_headers(src,_)
    src << "# Stimuli sequence;bin;XXX;explicit"
    src << "# Unobservables : XXX"
  end
end


def ateta_save_explicit_util(test_vecCouple)
  uut = TestAteta.new
  stim = {}
  stim[test_vecCouple] = ["XXX", "XXX"]
  uut.save_explicit_util(true, stim, 'test_genstim_bin_save_as_txt.txt', 1)
  'test_genstim_bin_save_as_txt.txt'
end

def verify_stim_writing_order(test_vecCouple, filename) 
    txt = File.read('test_genstim_bin_save_as_txt.txt')
    splitted_txt = txt.split("\n")
    index = 0
    splitted_txt.each do |line|
      unless line[0] == '#'
        line.chars.zip(test_vecCouple[index].chars) do |e, ref|
          if e != ref 
            raise "Error: Converter::GenStim.save_as_txt does not write test vectors in the expected order."
          end
        end
        index += 1
      end
    end
end

def test_ateta_save_explicit
    test_vecCouple = ["001","100"]
    stim_file = ateta_save_explicit_util(test_vecCouple)
    verify_stim_writing_order(test_vecCouple, stim_file)
end

Dir.chdir("tests/tmp") do 
  test_ateta_save_explicit
end