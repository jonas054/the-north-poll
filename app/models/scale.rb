# coding: utf-8

class Scale < ApplicationRecord
  has_many :polls, dependent: :destroy

  def self.default_lists
    [%w[1 2 3 4 5 6 7 8 9 10],
     %w[½ 1 2 3 5 8 13 20 40 100 ? ☕️],
     %w[Yes No],
     %w[👍 🤷‍♂️ 👎]]
  end

  def self.encode(string)
    array = if string.include?(';')
              string.split(/\s*;\s*/)
            else
              string.split
            end
    array.join(',')
  end

  def can_have_average?
    choices.all? { |item| number?(item) }
  end

  def choices
    list.split(',')
  end

  private

  def number?(string)
    true if Float(string) rescue false # rubocop:disable Style/RescueModifier
  end
end
