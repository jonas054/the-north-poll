class Scale < ApplicationRecord
  has_many :polls, dependent: :destroy

  def self.default_lists
    [%w[1 2 3 4 5 6 7 8 9 10],
     %w[☕ ½ 1 2 3 5 8 13 20 40 100 ?️],
     ['🐞 1', '🐀 2', '🐩 3', '🐑 5', '🐬 8', '🐪 13', '🐳 20',
      '🕷 1', '🦂 2', '🐍 3', '🐅 5', '🦈 8', '🦏 13', '🦖 20'],
     %w[S M L XL],
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

  def choices
    list.split(',')
  end
end
