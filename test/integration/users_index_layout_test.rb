require "test_helper"

class UsersIndexLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
     @user = User.first
  end


  test "layout links on index page from users path" do
    log_in_as(@user)
    assert is_logged_in?
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "layout links" do
    log_in_as(@user)
    assert is_logged_in?
    get users_path
    assert_template 'users/index'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path, count: 2
    assert_select "a[href=?]", contact_path, count: 2
    assert_select "a[href=?]", users_path
  end

  test "non-logged-in users behavior" do
    log_in_as(@user)
    get users_path
    assert_select "a[href=?]", users_path, count: 1
    delete logout_path
    assert_not is_logged_in?
    get users_path
    assert_redirected_to login_path
    assert_select "a[href=?]", users_path, count: 0
  end
end

