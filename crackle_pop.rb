# Write a program that prints out the numbers 1 to 100 (inclusive). 
# If the number is divisible by 3, print Crackle instead of the number. 
# If it's divisible by 5, print Pop instead of the number. 
# If it's divisible by both 3 and 5, print CracklePop instead of the number.
# You can use any language.

def crackle_pop(range, crackle: 3, pop: 5)
  range.map do |i|
    crackled = divisible_by?(i, crackle)
    popped = divisible_by?(i, pop)

    line = "#{"Crackle" if crackled}#{"Pop" if popped}#{i.to_s if not crackled and not popped}"
  end
end

def divisible_by?(x, y)
  x % y == 0
end

@test_num = 1

def assert_equals(actual, expected)
  if actual == expected
    puts "✅ Test #{@test_num} passed!"
  else
    raise "⛔️ Test failed! #{actual} != #{expected}"
  end

  @test_num += 1
end

def test_crackle_pop
  assert_equals(crackle_pop([15]), ["CracklePop"])
  assert_equals(crackle_pop([3]), ["Crackle"])
  assert_equals(crackle_pop([5]), ["Pop"])
  assert_equals(crackle_pop([1]), ["1"])
  assert_equals(crackle_pop([2]), ["2"])
  assert_equals(crackle_pop([7]), ["7"])
  assert_equals(
    crackle_pop(1..15), 
    ["1", "2", "Crackle", "4", "Pop", "Crackle", "7", "8", "Crackle", "Pop", "11", "Crackle", "13", "14", "CracklePop"]
  )
end

def main
  if ARGV.include? "test"
    test_crackle_pop
  else
    puts crackle_pop(1..100)
  end
end

main