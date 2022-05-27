class Vote < ApplicationRecord # :nodoc:
  belongs_to :poll

  def self.remove_old
    all.find_each { _1.destroy if _1.old? }
  end

  def old?
    updated_at < 1.month.ago
  end
end
