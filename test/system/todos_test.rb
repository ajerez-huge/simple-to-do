require "application_system_test_case"

class TodosTest < ApplicationSystemTestCase
  setup do
    Capybara.enable_aria_label = true
    @user = users(:one)
    visit login_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button "Log in"
  end

  test "logged-in user manages to-dos from the root page" do
    assert_text "Buy milk"
    assert_text "Write report"

    # create
    fill_in "New to-do", with: "Walk the dog"
    click_button "Add"
    assert_text "Walk the dog"
    assert_field "New to-do", with: ""

    # status badges and complete / uncomplete
    row = find("li", text: "Buy milk")
    assert row.has_text?("Incomplete")
    row.check 'Mark "Buy milk" as complete'
    assert_selector "li", text: /Buy milk.*Completed/m
    find("li", text: "Buy milk").uncheck 'Mark "Buy milk" as incomplete'
    assert_selector "li", text: /Buy milk.*Incomplete/m

    # sections: completed items move to the bottom list
    within("section[aria-label=Pending]") { assert_text "Buy milk" }
    within("section[aria-label=Completed]") { assert_text "Write report"; assert_no_text "Buy milk" }
    find("li", text: "Buy milk").check 'Mark "Buy milk" as complete'
    within("section[aria-label=Completed]") { assert_text "Buy milk" }
    within("section[aria-label=Pending]") { assert_no_text "Buy milk" }
    find("li", text: "Buy milk").uncheck 'Mark "Buy milk" as incomplete'
    within("section[aria-label=Pending]") { assert_text "Buy milk" }

    # edit (cancel, blank error, save)
    within(find("li", text: "Buy milk")) { click_button "Edit" }
    fill_in "Edit description", with: "Changed"
    click_button "Cancel"
    assert_text "Buy milk"
    assert_no_text "Changed"

    within(find("li", text: "Buy milk")) { click_button "Edit" }
    fill_in "Edit description", with: ""
    click_button "Save"
    assert_text "can't be blank"
    fill_in "Edit description", with: "Buy oat milk"
    click_button "Save"
    assert_text "Buy oat milk"

    page.save_screenshot(Rails.root.join("tmp/screenshots/todos.png").to_s)

    # delete (cancel then confirm)
    within(find("li", text: "Walk the dog")) { click_button "Delete" }
    within("[role=dialog]") { click_button "Cancel" }
    assert_text "Walk the dog"
    within(find("li", text: "Walk the dog")) { click_button "Delete" }
    within("[role=dialog]") { click_button "Delete" }
    assert_no_text "Walk the dog"
  end
end
