require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @todo = todos(:one_open)
  end

  test "unauthenticated users are redirected to login" do
    assert_no_difference -> { Todo.count } do
      post todos_path, params: { description: "x" }
    end
    assert_redirected_to login_path
    patch todo_path(@todo), params: { completed: true }
    assert_redirected_to login_path
    delete todo_path(@todo)
    assert_redirected_to login_path
  end

  test "creates a todo" do
    log_in_as(@user)
    assert_difference -> { @user.todos.count }, 1 do
      post todos_path, params: { description: "New item" }
    end
    assert_redirected_to root_path
    assert_not @user.todos.find_by(description: "New item").completed
  end

  test "rejects a blank description" do
    log_in_as(@user)
    assert_no_difference -> { Todo.count } do
      post todos_path, params: { description: "  " }
    end
    assert_redirected_to root_path
  end

  test "completes and uncompletes a todo" do
    log_in_as(@user)
    patch todo_path(@todo), params: { completed: true }
    assert_response :redirect
    assert @todo.reload.completed
    patch todo_path(@todo), params: { completed: false }
    assert_not @todo.reload.completed
  end

  test "edits the description" do
    log_in_as(@user)
    patch todo_path(@todo), params: { description: "Buy oat milk" }
    assert_response :redirect
    assert_equal "Buy oat milk", @todo.reload.description
  end

  test "rejects a blank edit" do
    log_in_as(@user)
    patch todo_path(@todo), params: { description: "" }
    assert_equal "Buy milk", @todo.reload.description
  end

  test "destroys a todo" do
    log_in_as(@user)
    assert_difference -> { Todo.count }, -1 do
      delete todo_path(@todo)
    end
    assert_redirected_to root_path
  end

  test "cannot modify another user's todo" do
    other = todos(:two_open)
    log_in_as(@user)
    patch todo_path(other), params: { completed: true }
    assert_response :not_found
    assert_not other.reload.completed
    assert_no_difference -> { Todo.count } do
      delete todo_path(other)
    end
    assert_response :not_found
  end

  private
    def log_in_as(user)
      post login_path, params: { email: user.email, password: "password" }
    end
end
