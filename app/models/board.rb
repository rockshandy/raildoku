class Board < ActiveRecord::Base
  has_many :solutions
  serialize :value

  validates_presence_of :width, :height
  #validate :constraints
  #TODO: validations, big one with board relation to width and height

  # for generating a set of board values given a string seperated by commas
  # or an array
  def self.generate_value(value,width=nil,height=nil)
    width ||= 3
    height ||= 3
    max = width.to_i * height.to_i

    if value.respond_to?('split')
      # then initial board was a string
      value = value.split(',')
    end

    # returns unless value is an array
    return nil unless value.kind_of?(Array)

    # initialize an array of empty arrays
    temp = Array.new(max) {Array.new}

    # goes through flat array and convert to multdimensional based on max
    value.each_with_index do |spot,i|
      temp[i/max][i % max] = spot.to_i
    end

    return temp
  end

  def to_s
    s = ''

    return 'invalid, check .errors' unless self.valid?

    self.value.each do | row |
      s << '|'
      row[0..-2].each_with_index do | val, i |
        s << val.to_s.center(4)
        (i+1) % self.width == 0 ? s << '||' : s << '|'
      end
      s << "#{row[-1].to_s.center(4)}|\n"
    end

    s
  end
end

