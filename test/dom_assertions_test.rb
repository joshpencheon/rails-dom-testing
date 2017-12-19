require 'test_helper'
require 'rails/dom/testing/assertions/dom_assertions'

class DomAssertionsTest < ActiveSupport::TestCase
  Assertion = Minitest::Assertion

  include Rails::Dom::Testing::Assertions::DomAssertions

  def test_responds_to_assert_dom_equal
    assert respond_to?(:assert_dom_equal)
  end

  def test_dom_equal
    html = '<a></a>'
    assert_dom_equal(html, html.dup)
  end

  def test_equal_doms_with_different_order_attributes
    attributes = %{<a b="hello" c="hello"></a>}
    reverse_attributes = %{<a c="hello" b="hello"></a>}
    assert_dom_equal(attributes, reverse_attributes)
  end

  def test_dom_equal_up_to_whitespace
    canonical = %{<a> <b>hello </b>world</a>}
    assert_dom_equal(canonical, %{<a>\n<b> hello </b>\nworld</a>})
    assert_dom_equal(canonical, %{<a> \n <b> hello </b>world</a>})
    assert_dom_equal(canonical, %{<a> \n <b>hello </b>world\n</a>\n})
    assert_dom_equal(canonical, %{<a>\n\t<b>hello </b>\n\tworld</a>})
    assert_dom_equal(canonical, <<~HTML)
      <a>
        <b>hello </b>
        world
      </a>
    HTML
  end

  def test_dom_not_equal_up_with_significant_whitespace
    with_space    = %{<a><b>hello</b> world</a>}
    without_space = %{<a><b>hello</b>world</a>}
    assert_dom_not_equal(with_space, without_space)
  end

  def test_dom_not_equal_up_with_boundary_whitespace
    space_before = %{<a><b>hello </b>world</a>}
    space_after  = %{<a><b>hello</b> world</a>}
    assert_dom_not_equal(space_before, space_after)
  end

  def test_dom_not_equal
    assert_dom_not_equal('<a></a>', '<b></b>')
  end

  def test_unequal_doms_attributes_with_different_order_and_values
    attributes = %{<a b="hello" c="hello"></a>}
    reverse_attributes = %{<a c="hello" b="goodbye"></a>}
    assert_dom_not_equal(attributes, reverse_attributes)
  end

  def test_custom_message_is_used_in_failures
    message = "This is my message."

    e = assert_raises(Assertion) do
      assert_dom_equal('<a></a>', '<b></b>', message)
    end

    assert_equal e.message, message
  end

  def test_unequal_dom_attributes_in_children
    assert_dom_not_equal(
      %{<a><b c="1" /></a>},
      %{<a><b c="2" /></a>}
    )
  end
end