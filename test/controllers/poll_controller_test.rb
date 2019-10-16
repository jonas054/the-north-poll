require 'test_helper'

class PollControllerTest < ActionDispatch::IntegrationTest
  test "should redirect create" do
    post 'http://www.example.com/poll', params: { title: 'Jonas' }
    assert_response :redirect
    assert_redirected_to %r'/poll/create_linked/\d+'
  end

  test "should show a poll" do
    get 'http://www.example.com/poll/22'
    assert_response :success
  end

  test "should show results" do
    get 'http://www.example.com/poll/22/results'
    assert_response :success
  end
end
