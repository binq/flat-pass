require 'openssl'
require 'yaml'

class Password
  attr_reader :password_length
  attr_reader :word_length
  attr_reader :separator
  
  def initialize(
    password_length: 24,
    word_length: 3..7,
    separator: '-'
  )
    @password_length = password_length
    @word_length = word_length
    @separator = separator

    (min, max) = %i(first last).map(&word_length.method(:public_send))

    raise "invalid password length: #{password_length}" unless password_length > 0
    raise "min word length can't be greater than max (#{min}, #{max})" unless min <= max
    raise "separator can only be one character" unless separator.length == 1
    raise "min has to be greater then 2" unless min > 2
    raise YAML::load(<<-EOM) unless max < (password_length / 3.0).ceil
    >
      Max word length (#{max}) has to be less
      than a third (#{(password_length / 3.0).ceil})
      of the password length (#{password_length})
    EOM
  end

  class_eval do
    first_char = 'a'.ord
    define_method :generate_chars do |l|
      OpenSSL::Random.random_bytes(l).each_byte.map { |x| (first_char + (x % 26)).chr }.join
    end
  end

  def generate_word(l, i) =
    generate_chars(l).then do |f|
      case
      when i == 0 && l < 7
        x = l - 1
        t = "%0#{x}u" 
        "#{f.slice(0, 1).capitalize}#{t % rand(10**x)}"
      when i == 0
        x = 2
        t = "%0#{x}u" 
        "#{f.slice(0, 1).capitalize}#{t % rand(10**x)}-#{f.slice(4, l)}"
      else
        f
      end
    end

  def decide_word_lengths = 
    password_length.then do |l|
      loop do
        case
        when l.zero?
          return
        when l > (2 * word_length.max + 2)
          n = rand(word_length)
          yield n
          l -= n + 1
        else
          n1 = (l / 2.0).floor
          yield n1
          l -= n1 + 1
          n2 = l
          yield n2
          l -= n2
        end
      end
    end

  def generate_password =
    enum_for(:decide_word_lengths)
      .each_with_index
      .map(&method(:generate_word))
      .join(separator)

  alias_method :to_s, :generate_password
end

(0...100).each do |i|
  puts "%02u: %s" % [i, Password.new]
end
