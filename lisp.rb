# Write code that takes some Lisp code and returns an abstract syntax tree.
# The AST should represent the structure of the code and the meaning of each token.
# For example, if your code is given "(first (list 1 (+ 2 3) 9))", 
# it could return a nested array like ["first", ["list", 1, ["+", 2, 3], 9]].

# During your interview, you will pair on writing an interpreter to run the AST. 
# You can start by implementing a single built-in function (for example, +) and add more if you have time.

# Useful reference: https://norvig.com/lispy.html

SPACE = " "
PARENS = ["(", ")"]
EOF = "EOF"

class Tokenizer
  def initialize(code)
    @tokens = []
    @current_token = []
    @code = code

    @chars = code.chars
    @chars.append(EOF)
  end

  def tokenize
    @chars.each do |char|
      case char
      when SPACE
        flush_current_token!
      when *PARENS
        flush_current_token!
        add_token!(char)
      when EOF
        flush_current_token!
      else
        @current_token.append(char)
      end
    end

    @tokens
  end

  def reset_current_token!
    @current_token = []
  end

  def add_token!(token) 
    @tokens.append(token)
  end

  def flush_current_token!
    if !(@current_token.empty?)
      add_token!(@current_token.join)
      reset_current_token!
    end
  end
end

class Testing
  def self.test_tokenizer
    assert_equals(Tokenizer.new("123").tokenize, ["123"])
    assert_equals(Tokenizer.new("(+ 1 2)").tokenize, ["(", "+", "1", "2", ")"])
    assert_equals(Tokenizer.new("(+ (+ 1 2) 34)").tokenize, ["(", "+", "(", "+", "1", "2", ")", "34", ")"])
    assert_equals(Tokenizer.new('(append "abc" "def")').tokenize, ["(", "append", '"abc"', '"def"', ")"])
  end

  def self.assert_equals(actual, expected)
    @@assertion_num += 1

    if actual == expected
      puts "- Check #{@@assertion_num} passed!"
      @@assertions_passed += 1
    else
      puts "-️ 💥 Check #{@@assertion_num} failed! #{actual} != #{expected}"
    end
  end

  def self.test
    puts "Testing..."
    puts ''

    self.methods.each do |method|
      if method.start_with?("test_")
        reset_state!

        puts "Running #{method}:"
        self.send(method)

        if @@assertions_passed == @@assertion_num
          puts "✅ Passed #{method}: #{@@assertion_num - @@assertions_passed} failures + #{@@assertions_passed} passed = #{@@assertion_num} total"
        else
          puts "⛔️ Failed #{method}: #{@@assertion_num - @@assertions_passed} failures + #{@@assertions_passed} passed = #{@@assertion_num} total"
        end

        puts ''
      end
    end
  end

  def self.reset_state!
    @@assertion_num = 0
    @@assertions_passed = 0
  end
end

def main
  if ARGV.include? "--test"
    Testing.test
  end
end

main