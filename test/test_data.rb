require('test/unit')
require('rubygems')
require('post')

class PostTest < Test::Unit::TestCase

  def test_packagelist
    assert_equal [], PackageList.new.to_a()
  end
  
end

