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
end
