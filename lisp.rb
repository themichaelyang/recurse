# Write code that takes some Lisp code and returns an abstract syntax tree.
# The AST should represent the structure of the code and the meaning of each token.
# For example, if your code is given "(first (list 1 (+ 2 3) 9))", 
# it could return a nested array like ["first", ["list", 1, ["+", 2, 3], 9]].

# During your interview, you will pair on writing an interpreter to run the AST. 
# You can start by implementing a single built-in function (for example, +) and add more if you have time.

# Useful reference: https://norvig.com/lispy.html
#
# I implemented a number of things differently -- for example, my tokenizer supports string literals 
# ("hello world"), which meant it couldn't use his neat add spaces to parens and split on whitespace trick.
#
# I found Norvig's `read_from_tokens` too clever (for me). It relies on CLOSE_PAREN being
# a String, so it can be returned by atom() for L.append(read_from_tokens(tokens)) to close the Expression. 
# I also found the state of the Array too hard to track of with pops, so I use indices and avoid treating
# parens as atoms.

SPACE = " "
QUOTE = '"'
OPEN_PAREN = "("
CLOSE_PAREN = ")"
PARENS = [OPEN_PAREN, CLOSE_PAREN]
NEWLINE = "\n"

# Not a token, only used by Tokenizer as a sentinel
EOF = "EOF"

# Produces tokens of:
# - Parenthesis: ( )
# - Symbols and Numbers: tomato, 42.
# - String literals: "hello world"
class Tokenizer
  def initialize(code)
    @tokens = []
    @current_token = []
    @code = code

    @chars = code.chars
    @chars.append(EOF)
  end

  def tokenize
    i = 0

    while i < @chars.length
      char = @chars[i]
      case char
      when SPACE
        flush_current_token!
      when *PARENS
        flush_current_token!
        add_token!(char)
      when QUOTE
        i = tokenize_string(i)
      when EOF
        flush_current_token!
      else
        @current_token.append(char)
      end

      i += 1
    end

    @tokens
  end

  def tokenize_string(i)
    initial = i
    @current_token.append(@chars[i])

    i = i + 1
    while @chars[i] != QUOTE
      if @chars[i] == EOF || @chars[i] == NEWLINE
        raise "Unclosed string at char #{initial}"
      end

      @current_token.append(@chars[i])
      i = i + 1
    end

    @current_token.append(@chars[i])
    flush_current_token!

    i
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

class Lexer
  def self.integer_literal?(str)
    str.to_i.to_s == str
  end

  def self.string_literal?(str)
    str.start_with?('"') && str.end_with?('"')
  end

  def self.boolean_literal?(str)
    str == "true" || str == "false"
  end

  def self.to_boolean(str)
    if str == "true"
      true
    elsif str == "false"
      false
    else
      raise "Not a boolean!"
    end
  end
end

#=== Grammar ====
# 
# Program is:
# S-expr[0]
# ...
# S-expr[n]
#
# (atoms would get discarded, but think of a REPL)
#
# S-expr ("Symbolic Expression") is either:
# - Expression: (Symbol S-expr[0] ... S-expr[n])
# - Atom
# 
# Atom is either:
# - String literal
# - Number literal
# - Boolean literal
# - Symbol
#
#================

# Different class for Expression and Program so we can distinguish them.
class Expression < Array; end

# A list of S-expr at the "top level"
class Program < Array; end

# parse_XY returns [XY, last_index], so we can resume from the next relevant token
class Parser
  def initialize(code)
    @code = code
    @tokens = Tokenizer.new(code).tokenize
  end

  def parse
    parse_program(@tokens)
  end

  def parse_program(tokens)
    program = Program.new
    i = 0
    token = tokens[i]

    until token.nil?
      s_expr, i = parse_symbolic_expression(@tokens, 0)
      program.append(s_expr)
      i += 1
      token = tokens[i]
    end

    program
  end

  def parse_symbolic_expression(tokens, i)
    token = tokens[i]

    if token == OPEN_PAREN
      parse_expression(tokens, i)
    else
      parse_atom(tokens, i)
    end
  end

  # Start on OPEN_PAREN, end on CLOSE_PAREN
  def parse_expression(tokens, i)
    expr = Expression.new
    _open_paren = tokens[i]

    i += 1
    token = tokens[i]

    until token == CLOSE_PAREN
      atom_or_subexpr, i = parse_symbolic_expression(tokens, i)
      expr.append(atom_or_subexpr)

      i += 1
      token = tokens[i]
    end

    [expr, i]
  end

  def parse_atom(tokens, i)
    token = tokens[i]
    Testing.debug_puts "#{__method__}: #{token}"

    atom = if Lexer.integer_literal?(token)
      token.to_i
    elsif Lexer.string_literal?(token)
      # Remove quotes
      token[1...-1]
    elsif Lexer.boolean_literal?(token)
      Lexer.to_boolean(token)
    else
      token.to_sym
    end

    [atom, i]
  end
end

class Context < Hash
  def initialize(parent)
    @parent = parent
    @bindings = {}
  end

  def set(**kv)
    @bindings.merge!(kv)
  end

  def get(symbol)
  end

  def builtins(symbol) 
    {
      :+ => lambda {|parameters| parameters.sum},
      :- => lambda {|parameters| parameters.first - parameters.last},
      :* => lambda {|parmeters| parameters.map(&:*)},
      :/ => lambda {|parameters| parameters.first / parameters.last}
    }
  end

  def guard_arity(parameters, num_parameters)
    if parameters.count != num_parameters
      raise ArgumentError.new("Wrong number of parameters")
    end
  end
end

class Interpreter
  # ast = parsed list structure with tokens
  def initialize(code)
    @code = code 
    @ast = Parser.new(@code).parse
  end

  # accepts a Program (list of expressions)
  def interpret
    @ast.map do |s_expr| 
      interpret_symbolic_expression(s_expr)
    end.last
  end

  def interpret_symbolic_expression(s_expr)
    if s_expr.is_a? Array
      interpret_expression(s_expr)
    else
      interpret_atom(s_expr)
    end
  end

  def interpret_expression(expr)
    function = expr.first
    parameters = (expr[1..-1]).map do |p|
      interpret_symbolic_expression(p)
    end

    if function == :+
      parameters.sum
    end
  end

  def interpret_atom(atom)
    atom
  end
end

# A self contained testing singleton that tests every method starting with `test_*`
class Testing
  def self.debug_puts(*params)
    if @debug
      puts(params)
    end
  end

  def self.test_tokenizer
    assert_equals(Tokenizer.new("123").tokenize, ["123"])
    assert_equals(Tokenizer.new("(+ 1 2)").tokenize, ["(", "+", "1", "2", ")"])
    assert_equals(Tokenizer.new("(+ (+ 1 2) 34)").tokenize, ["(", "+", "(", "+", "1", "2", ")", "34", ")"])
    assert_equals(Tokenizer.new('(append "abc" "def")').tokenize, ["(", "append", '"abc"', '"def"', ")"])
    assert_equals(Tokenizer.new('"hello world"').tokenize, ['"hello world"'])
    assert_equals(Tokenizer.new('(append "hello world" " michael!")').tokenize, ["(", "append", '"hello world"', '" michael!"', ")"])
    assert_equals(Tokenizer.new('("1 + 2")').tokenize, ["(", '"1 + 2"', ")"])
  end

  def self.test_parser
    assert_equals(Parser.new("(123)").parse, [[123]])
    assert_equals(Parser.new("(+ 1 2)").parse, [[:+, 1, 2]])
    assert_equals(Parser.new("(+ 1 2 3)").parse, [[:+, 1, 2, 3]])
    assert_equals(Parser.new("(+ 1 (+ 2 3))").parse, [[:+, 1, [:+, 2, 3]]])
    assert_equals(Parser.new('(append "hello world" " michael!")').parse, [[:append, "hello world", " michael!"]])
    assert_equals(Parser.new("(+ (* 1 2 3) (- 4 5) (/ 6 7))").parse, [[:+, [:*, 1, 2, 3], [:-, 4, 5], [:/, 6, 7]]])
    assert_equals(Parser.new("(and true false)").parse, [[:and, true, false]])
    assert_equals(Parser.new("123").parse, [123])
  end

  def self.test_interpreter
    assert_equals(Interpreter.new("(+ 1 1)").interpret, 2)
    assert_equals(Interpreter.new("(+ 1 2 3)").interpret, 6)
    assert_equals(Interpreter.new("(+ 1 (+ 2 3))").interpret, 6)
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

    self.methods.reverse.each do |method|
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

  def self.enable_debug!
    @debug = true
  end

  def self.reset_state!
    @@assertion_num = 0
    @@assertions_passed = 0
  end
end

def main
  if ARGV.include? "--debug"
    Testing.enable_debug!
  end

  if ARGV.include? "--test"
    Testing.test
  end
end

main