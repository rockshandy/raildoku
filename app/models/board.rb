class Board < ActiveRecord::Base
  serialize :value

  validates_presence_of :width, :height
  #validate :constraints
  #TODO: validations, big one with board relation to width and height

  def self.should_andy_really_learn_to_make_shorter_method_names_i_mean_seriously_and_whats_the_deal_with_lower_camel_case?
    true
  end

  # for generating a set of board values given a string seperated by commas
  # or an array
  def self.generate_value(value,width=3,height=3)
    max = width * height

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
      temp[i/max][i % max] = spot
    end

    return temp
  end

  def to_s
    s = ''

    return 'invalid, check .errors' unless self.valid?

    self.value.each do | row |
      s << '|'
      row[0..-2].each_with_index do | val, i |
        s << val.center(4)
        (i+1) % self.width == 0 ? s << '||' : s << '|'
      end
      s << "#{row[-1].center(4)}|\n"
    end

    s
  end
end

