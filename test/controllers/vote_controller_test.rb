require 'test_helper'

class VoteControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get vote_index_url
    assert_response :success
  end

  test 'should create vote and redirect to results' do
    assert_equal 2, votes.size
    assert_equal 2, Vote.all.size
    post 'http://www.example.com/vote',
         params: { poll: { id: 22 }, vote: { value: '10' } }
    assert_redirected_to %r{/poll/22/results}
    assert_equal 3, Vote.all.size
    assert_equal '10', Vote.last.content
    assert_equal 22, Vote.last.poll_id
  end
end
