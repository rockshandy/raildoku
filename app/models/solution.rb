class Solution < ActiveRecord::Base
  belongs_to :board
  serialize :value

  # to easily convert a board value back to a comma spearted list for ajax return
  def decode
    self.value.flatten.join(',')
  end

  def to_s
    s = ''

    return 'invalid, check .errors' unless self.valid?

    self.value.each do | row |
      s << '|'
      row[0..-2].each_with_index do | val, i |
        s << val.to_s.center(4)
        (i+1) % self.board.width == 0 ? s << '||' : s << '|'
      end
      s << "#{row[-1].to_s.center(4)}|\n"
    end

    s += "Time: #{self.time}(s), Boards Generated: #{self.generated}"
  end
end

