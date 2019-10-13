require 'test_helper'

class PollControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get poll_new_url
    assert_response :success
  end

end
