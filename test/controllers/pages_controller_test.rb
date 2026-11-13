require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "logged-out visitors see the landing page" do
    get root_path
    assert_response :success
    assert_equal "Home", inertia_page["component"]
  end

  test "logged-in users see only their own todos at root" do
    post login_path, params: { email: users(:one).email, password: "password" }
    get root_path
    assert_response :success
    page = inertia_page
    assert_equal "Todos", page["component"]
    descriptions = page["props"]["todos"].map { |t| t["description"] }
    assert_equal [ "Buy milk", "Write report" ], descriptions.sort
  end

  private
    def inertia_page
      node = Nokogiri::HTML(response.body).at_css("[data-page]")
      JSON.parse(node["data-page"])
    end
end
