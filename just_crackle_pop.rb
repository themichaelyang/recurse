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