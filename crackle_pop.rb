# Run me:
# > ruby crackle_pop.rb

# Write a program that prints out the numbers 1 to 100 (inclusive). 
# If the number is divisible by 3, print Crackle instead of the number. 
# If it's divisible by 5, print Pop instead of the number. 
# If it's divisible by both 3 and 5, print CracklePop instead of the number.
# You can use any language.

def crackle_pop(range, crackle: 3, pop: 5)
  range.map do |i|
    crackled = i.divisible_by? crackle
    popped = i.divisible_by? pop

    "#{"Crackle" if crackled}#{"Pop" if popped}#{i.to_s if !crackled && !popped}"
  end
end

class Integer
  def divisible_by?(divisor)
    self % divisor == 0
  end
end

puts crackle_pop(1..100)

# Everything below is just for testing! Feel free to ignore.
#
# Test me:
# > ruby crackle_pop.rb --test

class Testing
  @@test_num = 1

  def self.assert_equals(actual, expected)
    if actual == expected
      puts "✅ Test #{@@test_num} passed!"
    else
      puts "⛔️ Test #{@@test_num} failed! #{actual} != #{expected}"
    end

    @@test_num += 1
  end

  def self.test_crackle_pop
    assert_equals(crackle_pop([1, 2, 7]), ["1", "2", "7"])
    assert_equals(crackle_pop([3]), ["Crackle"])
    assert_equals(crackle_pop([6]), ["Crackle"])
    assert_equals(crackle_pop([5]), ["Pop"])
    assert_equals(crackle_pop([10]), ["Pop"])
    assert_equals(crackle_pop([15]), ["CracklePop"])
    assert_equals(
      crackle_pop(1..15), 
      ["1", "2", "Crackle", "4", "Pop", "Crackle", "7", "8", "Crackle", "Pop", "11", "Crackle", "13", "14", "CracklePop"]
    )
  end
end

if ARGV.include? "--test"
  Testing.test_crackle_pop
end