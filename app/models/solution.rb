class Solution < ActiveRecord::Base
  belongs_to :board
  serialize :value
end

