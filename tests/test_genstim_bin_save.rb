require_relative '../lib/netenos'

# Tests if stimulus are written in the right order when using the binary format

# Methods to be tested :
# - Converter::GenStim.save_as_txt
 
# Test procedure :
# Prepare a text vector (or a few) wih is not symetrical (001 is OK, 101 is NOT OK)
# Save it with the method to be tested
# Reaf the file and compare with the expected. 
# The bits are supposed to be written in the same order as in the ruby array. That is to say the bit that is at the far most left should correspond to the index 0 in the ruby array, the far most right should correspond to the greatest index in the ruby array :
# Index in ruby array     : 0    1    2
# Value in ruby array     : 0    0    1
# Value in file (ordered) : 0    0    1

def genstim_save_as_txt(test_vec)
  uut = Converter::GenStim.new()
  stim = {}
  test_vec.chars.each_with_index do |e, i|
    stim["i#{i}"] = e
  end
  uut.stim = stim
  uut.save_as_txt('test_genstim_bin_save_as_txt.txt', bin_stim_vec: 'bin')
  'test_genstim_bin_save_as_txt.txt'
end

def verify_stim_writing_order(test_vec, filename) 
   txt = File.read('test_genstim_bin_save_as_txt.txt')
    splitted_txt = txt.split("\n")
    splitted_txt.each do |line|
      unless line[0] == '#'
        line.chars.zip(test_vec.chars) do |e, ref|
          if e != ref 
            raise "Error: Converter::GenStim.save_as_txt does not write test vectors in the expected order."
          end
        end
      end
    end
end

def test_genstim_save_as_txt
    test_vec = "001"
    stim_file = genstim_save_as_txt(test_vec)
    verify_stim_writing_order(test_vec, stim_file)
end

Dir.chdir("tests/tmp") do 
  test_genstim_save_as_txt
end