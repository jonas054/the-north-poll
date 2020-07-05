require 'test_helper'

class ScaleTest < ActiveSupport::TestCase
  test 'encode can handle spaces' do
    assert_equal '1,2,3', Scale.encode('1 2 3')
  end

  test 'encode can handle semi-colons' do
    assert_equal "Yes of course,No way,I don't know",
                 Scale.encode("Yes of course;No way ; I don't know")
  end
end
