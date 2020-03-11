require 'test_helper'

class PollControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect create' do
    assert_equal 2, Poll.count
    post 'http://www.example.com/poll',
         params: { title: 'Jonas', scale: { list: 'Yes,No' } }
    assert_response :redirect
    assert_redirected_to %r{/poll/create_linked/\d+}
    assert_equal 3, Poll.count
    assert_equal 'Jonas', Poll.last.title
    assert_equal 'Yes,No', Poll.last.scale.list
  end

  test 'should show a poll' do
    get 'http://www.example.com/poll/22'
    assert_response :success
  end

  test 'should show a list' do
    get 'http://www.example.com/poll/list/22'
    assert_response :success
  end

  test 'should show results' do
    get 'http://www.example.com/poll/22/results'
    assert_response :success
  end

  test 'should remove old polls from database' do
    assert_equal ['First poll', 'Second poll'], Poll.all.map(&:title)
    assert_equal 2, Vote.count
    assert_equal 2, Scale.count

    # Make a poll and all its votes too old to keep.
    poll = Vote.last.poll
    poll.update(updated_at: 1.year.ago)
    poll.votes.each { |vote| vote.update(updated_at: 1.year.ago) }

    # Create a new poll.
    post 'http://www.example.com/poll',
         params: { title: 'New poll', scale: { list: 'Yes,No' } }

    # A new poll is created and the old one is removed.
    assert_equal ['Second poll', 'New poll'], Poll.all.map(&:title)
    # The votes belonging to that poll are also removed.
    assert_equal 0, Vote.count
    # The scale that no longer has any polls is also removed.
    assert_equal 1, Scale.count
  end

  test 'should archive old votes' do
    post 'http://www.example.com/poll',
         params: { title: 'ABC', scale: { list: 'Yes,No' } }
    poll = Poll.where(title: 'ABC').first
    poll.votes << Vote.create(updated_at: 1.year.ago) << Vote.create
    assert !poll.votes.first.is_archived
    assert !poll.votes.last.is_archived
    get "http://www.example.com/poll/#{poll.id}"
    assert_response :success
    assert poll.votes.first.is_archived
    assert !poll.votes.last.is_archived
  end
end
