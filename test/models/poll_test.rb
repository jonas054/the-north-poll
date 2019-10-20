require 'test_helper'

class PollTest < ActiveSupport::TestCase
  test "#average should return the average of vote contents" do
    poll = Poll.create
    poll.votes << Vote.create(content: "7") << Vote.create(content: "8")
    assert_equal 7.5, poll.average
  end

  test "#results should return all votes" do
    poll = Poll.create(id: 19)
    poll.votes << Vote.create(content: "7") << Vote.create(content: "8")
    assert_equal [7, 8], poll.results.keys
    (7..8).each do |choice|
      result = poll.results[choice]
      assert_equal 1, result.size
      assert_equal 19, result.first.poll_id
      assert_equal choice.to_s, result.first.content
    end
  end

  test "#can_have_average? should return true if all choices are numbers" do
    poll = Poll.create(scale: Scale.new(list: '1,2,3,4,5,6,7,8,9,10'))
    assert_equal true, poll.can_have_average?
  end

  test "#can_have_average? should return false if not all choices are numbers" do
    poll = Poll.create(scale: Scale.new(list: '½,1,2,3,5,8,13,20,40,100,?,☕️'))
    assert_equal false, poll.can_have_average?
  end
end
