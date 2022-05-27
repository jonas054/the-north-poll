class Vote < ApplicationRecord # :nodoc:
  belongs_to :poll

  def old?(age_limit)
    updated_at < age_limit
  end
end
