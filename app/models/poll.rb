class Poll < ApplicationRecord
  has_many :votes, dependent: :destroy
  belongs_to :scale

  include ActionView::Helpers::TextHelper # pluralize()
  include PollHelper # to_number()

  def sum_up
    total = results.sort_by { |_, votes| -votes.size }.map do |key, votes|
      "#{key}: #{pluralize(votes.size, 'vote')}"
    end
    total.join(', ')
  end

  def results
    if can_have_average?
      votes.group_by { |v| to_number(v.content) }
    else
      votes.group_by(&:content)
    end
  end

  def average
    votes.map { |v| v.content.to_f }.reduce(0.0, :+) / votes.size
  end

  delegate :can_have_average?, :choices, to: :scale

  def chain
    if previous_poll_id
      Poll.find(previous_poll_id).chain + [self]
    else
      [self]
    end
  end

  def remove_links_to
    if previous_poll_id && Poll.exists?(previous_poll_id)
      Poll.update(previous_poll_id, next_poll_id: nil)
    end
    if next_poll_id && Poll.exists?(next_poll_id)
      Poll.update(next_poll_id, previous_poll_id: nil)
    end
  end
end
