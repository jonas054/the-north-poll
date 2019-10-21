# coding: utf-8

class Scale < ApplicationRecord
  def self.default_lists
    [%w[1 2 3 4 5 6 7 8 9 10],
     %w[½ 1 2 3 5 8 13 20 40 100 ? ☕️],
     %w[Yes No],
     %w[👍 👎]]
  end

  def can_have_average?
    list.split(',').all? { |item| item.to_i.to_s == item }
  end
end
