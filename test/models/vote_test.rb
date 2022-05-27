require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  test 'remove_old should remove archived votes that are older than 1 month' do
    old_date = 2.months.ago
    poll = Poll.create(id: 1, scale: Scale.create(list: '1,2,3,4,5,6,7,8,9,10'))
    poll.votes << Vote.create(content: '1', is_archived: false, updated_at: old_date)
    poll.votes << Vote.create(content: '1', is_archived: true, updated_at: old_date)

    assert_equal 2, poll.votes.count

    Vote.remove_old

    assert_equal 0, poll.votes.count
  end
end
