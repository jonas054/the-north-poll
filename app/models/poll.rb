class Poll < ApplicationRecord
  has_many :votes

  def results
    votes.group_by { |v| v.content.to_i }
  end

  def average
    votes.map { |v| v.content.to_f }.reduce(:+) / votes.size
  end
end
