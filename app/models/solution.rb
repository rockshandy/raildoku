class Solution < ActiveRecord::Base
  belongs_to :board
  serialize :value

  # to easily convert a board value back to a comma spearted list for ajax return
  def decode
    self.value.flatten.join(',')
  end
end

