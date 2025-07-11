# Write code that takes some Lisp code and returns an abstract syntax tree.
# The AST should represent the structure of the code and the meaning of each token.
# For example, if your code is given "(first (list 1 (+ 2 3) 9))", 
# it could return a nested array like ["first", ["list", 1, ["+", 2, 3], 9]].

# During your interview, you will pair on writing an interpreter to run the AST. 
# You can start by implementing a single built-in function (for example, +) and add more if you have time.

# Useful reference: https://norvig.com/lispy.html

class AST < Array
end

class Tokenizer
  def initialize(code)
    @tokens = []
    @current_token = []
    @code = code
  end

  def tokenize
    @code.chars.each do |char|
      case char
      when " "
        flush_current_token!
      when "("
        flush_current_token!
        add_token!(char)
      when ")"
        flush_current_token!
        add_token!(char)
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

puts Tokenizer.new("(+ (+ 1 2) 3)").tokenize.inspect