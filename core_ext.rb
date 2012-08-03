class String
  def colour(code)
     "\e[#{code}m#{self}\e[0m"
  end

  colours = {
    red: 31
  }

  colours.each do |name, code|
    define_method name do
      colour(code)
    end
  end
end

class Array
  def clip n=1
    take size-n
  end
end