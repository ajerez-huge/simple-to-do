require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "is valid with a description" do
    assert Todo.new(user: users(:one), description: "Do it").valid?
  end

  test "requires a description" do
    todo = Todo.new(user: users(:one), description: "   ")
    assert_not todo.valid?
    assert todo.errors[:description].any?
  end

  test "strips whitespace and limits length" do
    assert_equal "Do it", Todo.new(description: "  Do it ").description
    assert_not Todo.new(user: users(:one), description: "a" * 501).valid?
  end

  test "defaults to incomplete" do
    assert_not Todo.new.completed
  end
end
