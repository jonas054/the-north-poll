class Poll < ApplicationRecord
  has_many :votes, dependent: :restrict_with_exception
  belongs_to :scale

  include ApplicationHelper

  def choices
    return (1..10).map(&:to_s) unless scale

    scale.list.split(/\s*,\s*/)
  end

  def results
    if votes.all? { |v| v.content.to_i.to_s == v.content }
      votes.group_by { |v| v.content.to_i }
    else
      votes.group_by(&:content)
    end
  end

  def average
    votes.map { |v| v.content.to_f }.reduce(0.0, :+) / votes.size
  end

  delegate :can_have_average?, to: :scale

  def chain
    if previous_poll_id
      Poll.find(previous_poll_id).chain + [self]
    else
      [self]
    end
  end

  def sum_up
    total = results.sort_by { |_, votes| -votes.size }.map do |key, votes|
      "#{key}: #{votes.size} #{plural_s('vote', votes.size)}"
    end
    total.join(', ')
  end

  def remove_links_to
    Poll.update(previous_poll_id, next_poll_id: null) if previous_poll_id
    Poll.update(next_poll_id, previous_poll_id: null) if next_poll_id
  end
end
