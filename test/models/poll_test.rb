require 'test_helper'

class PollTest < ActiveSupport::TestCase
  test 'Poll.all should return fixtures' do
    assert_equal [22, 33], Poll.all.map(&:id)
  end

  test '#average should return the average of vote contents' do
    assert_equal 2.5, Poll.find(22).average
  end

  test '#average should return not-a-number for no votes' do
    assert Poll.create.average.nan?
  end

  test '#standard_deviation should return the standard deviation of vote contents' do
    poll = Poll.create(id: 1, scale: Scale.create(list: '1,2,3,4,5,6,7,8,9,10'))
    poll.votes << Vote.create(content: '1')
    assert_equal 0, poll.standard_deviation
    poll.votes << Vote.create(content: '1')
    assert_equal 0, poll.standard_deviation
    poll.votes << Vote.create(content: '3') << Vote.create(content: '3')
    assert_equal 1, poll.standard_deviation # sqrt((1+1+1+1)/4)
  end

  test '#current_votes should return votes that are not archived' do
    poll = Poll.create(id: 1, scale: Scale.create(list: '1,2,3,4,5,6,7,8,9,10'))
    poll.votes << Vote.create(content: '1', is_archived: false)
    assert_equal 0, poll.standard_deviation
    poll.votes << Vote.create(content: '1', is_archived: true)
    assert_equal 0, poll.standard_deviation
    poll.votes << Vote.create(content: '3') << Vote.create(content: '3')
    assert_equal %w[1 3 3], poll.current_votes.map(&:content)
  end

  test '#results should return all votes' do
    poll = Poll.find(22)
    assert_equal %w[2 3], poll.results.keys
    poll.results.each_key do |choice|
      result = poll.results[choice]
      assert_equal 1, result.size
      assert_equal 22, result.first.poll_id
      assert_equal choice.to_s, result.first.content
    end
  end

  test '#results should return float keys' do
    poll = Poll.create(id: 1, scale: Scale.create(list: '1.5,2,2.5'))
    poll.votes << Vote.create(content: '1.5') << Vote.create(content: '2')
    assert_equal %w[1.5 2], poll.results.keys
    poll.results.each_key do |choice|
      result = poll.results[choice]
      assert_equal 1, result.size
      assert_equal 1, result.first.poll_id
      assert_equal choice.to_s, result.first.content
    end
  end

  test '#can_have_average? should return true if all choices are numbers' do
    poll = Poll.create(id: 7, scale: Scale.new(list: '1,2,3,4,5,6,7,8,9,10'))
    assert_equal true, poll.can_have_average?
  end

  test '#can_have_average? should return false if not all votes are numbers' do
    poll = Poll.create(scale: Scale.new(list: '☕️,½,1,2,3,5,8,13,20,40,100,?'))
    poll.votes << Vote.create(content: '1') << Vote.create(content: '☕️')
    assert_equal false, poll.can_have_average?
  end

  test 'can_have_average? returns true for a list containing only integers' do
    poll = Poll.create(scale: Scale.new(list: '1,2,3,4,5,6,7,8,9,10'))
    poll.votes << Vote.create(content: '1') << Vote.create(content: '2')
    assert poll.can_have_average?
  end

  test 'can_have_average? returns true for a list containing integers and floats' do
    poll = Poll.create(scale: Scale.new(list: '1,1.5,2,2.5,3'))
    poll.votes << Vote.create(content: '1.5') << Vote.create(content: '2')
    assert poll.can_have_average?
  end

  test '#remove_links_to should remove link from previous and next poll' do
    poll1 = Poll.create(scale: Scale.new(list: '1,2,3'))
    poll2 = Poll.create(scale: Scale.new(list: '1,2,3'), previous_poll_id: poll1.id)
    poll3 = Poll.create(scale: Scale.new(list: '1,2,3'), previous_poll_id: poll2.id)
    Poll.update(poll1.id, next_poll_id: poll2.id)
    Poll.update(poll2.id, next_poll_id: poll3.id)
    Poll.update(poll2.id, previous_poll_id: poll1.id)
    Poll.update(poll3.id, previous_poll_id: poll2.id)
    Poll.find(poll2.id).remove_links_to
    assert_nil Poll.find(poll1.id).next_poll_id
    assert_nil Poll.find(poll3.id).previous_poll_id
  end
end
