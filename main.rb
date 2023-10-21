require 'yaml'

class Password
  attr :password_length
  attr :word_length
  attr :separator
  
  def initialize(
    password_length: 24,
    word_length: {min: 3, max: 7},
    separator: '-'
  )
    @password_length = password_length
    @word_length = word_length
    @separator = separator

    word_length => {min:, max:}

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
        
  def generate_char(_)
    (97 + rand(26)).chr
  end
  
  def generate_word(l, i)
    try = (0...l).map(&method(:generate_char)).join('')

    case
    when 0 == i
      num = "%02u" % rand(100)
      result = "#{try.slice(0, 1).capitalize}#{num}#{try.slice(3, try.length)}"
    else
      result = try
    end

    result
  end

  def decide_word_lengths(range, l)
    loop do
      case
      when l.zero?
        return
      when l > (2 + range.max + range.max)
        n = rand(range)
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

  def generate_password
    word_length => {min:, max:}

    enum_for(:decide_word_lengths, min..max, password_length)
      .each_with_index
      .map(&method(:generate_word))
      .join(separator)
  end

  alias_method :to_s, :generate_password
end

puts "Hello, World!"
(0...100).each do |i|
  passwd = Password.new
  puts "#{"%02u" % i}: #{passwd}"
end
