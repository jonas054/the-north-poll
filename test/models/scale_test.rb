# coding: utf-8

require 'test_helper'

class ScaleTest < ActiveSupport::TestCase
  test 'can_have_average? returns true for a list containing only integers' do
    assert Scale.create(list: '1,2,3,4,5,6,7,8,9,10').can_have_average?
  end

  test 'can_have_average? returns true for a list containing integers and an ' \
       'emoji' do
    s = Scale.create(list: '½,1,2,3,5,8,13,20,40,100,?,☕️')
    assert_equal false, s.can_have_average?
  end

  test 'can_have_average? returns true for a list containing integers and ' \
       'floats' do
    s = Scale.create(list: '1,1.5,2,2.5,3')
    assert s.can_have_average?
  end
end
