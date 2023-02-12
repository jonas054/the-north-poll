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

  test '.remove_old should remove polls and votes that are older than 1 month' do
    old_date = 2.months.ago
    scale = Scale.create(list: '1,2,3,4,5,6,7,8,9,10')
    poll0 = create_poll_with_votes(scale, old_date)
    poll1 = create_poll_with_votes(scale, old_date)
    poll2 = create_poll_with_votes(scale, 2.days.ago)

    link(poll1, poll2)
    Poll.update(poll1.id, updated_at: old_date)
    Poll.update(poll2.id, updated_at: old_date)

    # Polls and votes exist before calling remove_old.
    [poll0, poll1, poll2].each do |poll|
      assert_equal old_date.month, Poll.find(poll.id).updated_at.month
      Poll.find(poll.id)
      poll.votes.each { Vote.find(_1.id) }
    end

    Poll.remove_old

    # Unchained old polls and votes don't exist after calling remove_old.
    assert_raises(ActiveRecord::RecordNotFound) { Poll.find(poll0.id) }
    poll0.votes.each do |v|
      assert_raises(ActiveRecord::RecordNotFound) { Vote.find(v.id) }
    end

    # Newer polls and old polls chained to newer polls still exist.
    [poll1, poll2].each do |poll|
      # assert_equal old_date.month, Poll.find(poll.id).updated_at.month
      Poll.find(poll.id)
      poll.votes.each { Vote.find(_1.id) }
    end
  end

  def create_poll_with_votes(scale, updated_at)
    poll = Poll.create(scale: scale, updated_at: updated_at)
    poll.votes << Vote.create(content: '1', is_archived: false, updated_at: updated_at)
    poll.votes << Vote.create(content: '1', is_archived: true, updated_at: updated_at)
    poll.votes << Vote.create(content: '3', updated_at: updated_at)
    poll.votes << Vote.create(content: '3', updated_at: updated_at)
    poll
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

  test '#can_have_average? should return false if there are no votes' do
    poll = Poll.create(id: 7, scale: Scale.new(list: '1,2,3,4,5,6,7,8,9,10'))
    assert_equal false, poll.can_have_average?
  end

  test '#can_have_average? should return false if only one vote is a number' do
    poll = Poll.create(scale: Scale.new(list: '☕️,½,1,2,3,5,8,13,20,40,100,?'))
    poll.votes << Vote.create(content: '1') << Vote.create(content: '☕️')
    assert_equal false, poll.can_have_average?
    assert_equal ['1', '☕️'], poll.results.keys
  end

  test '#can_have_average? should return true if two votes are numbers' do
    poll = Poll.create(scale: Scale.new(list: '🐞 1,🐀 2,🐩 3,🐑 5,🐬 8,🐪 13,🐳 20,🤷‍♂️,' \
                                              '🕷 1,🦂 2,🐍 3,🐆 5,🦈 8,🦏 13,🦖 20'))
    poll.votes <<
      Vote.create(content: '🐩 3') <<
      Vote.create(content: '🐑 5') <<
      Vote.create(content: '🤷‍♂️')
    assert_equal true, poll.can_have_average?
    assert_equal 4, poll.average
    assert_equal ['🐩 3', '🐑 5', '🤷‍♂️'], poll.results.keys
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
    link(poll1, poll2)
    link(poll2, poll3)
    Poll.find(poll2.id).remove_links_to
    assert_nil Poll.find(poll1.id).next_poll_id
    assert_nil Poll.find(poll3.id).previous_poll_id
  end

  test '.reset_to_alphabetical sets titles to A;B;C... if titles are edited a long time ago' do
    chain = build_chain(%w[X-001 X-002 X-003 D E F])
    fake_old_timestamps(chain)
    Poll.reset_to_alphabetical
    assert_equal %w[A B C D E F],
                 Poll.find(chain.first.id).find_chain.map { |poll| poll.title }
  end

  test '.reset_to_alphabetical does nothing if all titles are edited recently' do
    chain = build_chain(%w[X-001 X-002 X-003 D E F])
    Poll.reset_to_alphabetical
    assert_equal %w[X-001 X-002 X-003 D E F],
                 Poll.find(chain.first.id).find_chain.map { |poll| poll.title }
  end

  test '.reset_to_alphabetical does nothing if some titles are edited recently' do
    chain = build_chain(%w[X-001 X-002 X-003 D E F])
    fake_old_timestamps(chain[0..1])
    Poll.reset_to_alphabetical
    assert_equal %w[X-001 X-002 X-003 D E F],
                 Poll.find(chain.first.id).find_chain.map { |poll| poll.title }
  end

  test '.reset_to_alphabetical does nothing if chain does not end alphabetically' do
    chain = build_chain(%w[X-001 X-002 X-003 D E F ZZ])
    fake_old_timestamps(chain)
    Poll.reset_to_alphabetical
    assert_equal %w[X-001 X-002 X-003 D E F ZZ],
                 Poll.find(chain.first.id).find_chain.map { |poll| poll.title }
  end

  test '.reset_to_alphabetical does nothing if there are current votes' do
    chain = build_chain(%w[X-001 X-002 X-003 D E F])
    chain.first.votes << Vote.create(content: '1.5') << Vote.create(content: '2')
    fake_old_timestamps(chain)
    Poll.reset_to_alphabetical
    assert_equal %w[X-001 X-002 X-003 D E F],
                 Poll.find(chain.first.id).find_chain.map { |poll| poll.title }
  end

  test '.reset_to_alphabetical sets to A;B;C... if there are only archived votes' do
    chain = build_chain(%w[X-001 X-002 X-003 D E F])
    chain.first.votes << Vote.create(content: '1.5', is_archived: true)
    fake_old_timestamps(chain)
    Poll.reset_to_alphabetical
    assert_equal %w[A B C D E F],
                 Poll.find(chain.first.id).find_chain.map { |poll| poll.title }
  end

  def build_chain(titles)
    scale = Scale.new(list: '1,2,3')
    previous = nil
    titles.each do |title|
      poll = Poll.create(scale: scale, title: title)
      link(previous, poll) if previous
      previous = poll
    end
    Poll.find(previous.id).find_chain
  end

  def fake_old_timestamps(chain)
    ActiveRecord::Base.record_timestamps = false
    chain.each { |poll| Poll.update(poll.id, updated_at: 1.day.ago) }
    ActiveRecord::Base.record_timestamps = true
  end

  def link(poll1, poll2)
    Poll.update(poll1.id, next_poll_id: poll2.id)
    Poll.update(poll2.id, previous_poll_id: poll1.id)
  end
end
