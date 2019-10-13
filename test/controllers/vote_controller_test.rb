require 'test_helper'

class VoteControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get vote_index_url
    assert_response :success
  end

end
