require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                    password:"Foobar$3", password_confirmation: "Foobar$3")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@exmample,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.org foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be valid, like this: user@example.com"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should contain at least one symbol" do
    @user.password = @user.password_confirmation = "pep7eCapo"
    assert_not @user.valid?, "Password should contain at least one symbol"
  end

  test "password should contain at least one number" do
    @user.password = @user.password_confirmation = "pepeCapo"
    assert_not @user.valid?, "Password should contain at least one number"
  end

  test "password should not contain only characters" do
    @user.password = @user.password_confirmation = "password"
    assert_not @user.valid?, "Password should not contain only characters"
  end
  test "password should not contain only numbers" do
    @user.password = @user.password_confirmation = "12345678"
    assert_not @user.valid?, "Password should not contain only numbers"
  end

  test "Password should contain at least one number" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?, "Password should contain at least one number"
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember,'')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "I'ts a Trap!")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end


  test "should follow and unfollow a user" do
    nacho = users(:nacho)
    archer = users(:archer)
    assert_not nacho.following?(archer)
    nacho.follow(archer)
    assert nacho.following?(archer)
    assert archer.followers.include?(nacho)
    nacho.unfollow(archer)
    assert_not nacho.following?(archer)
    # Los usuarios no se pueden seguir a si mismos
    nacho.follow(nacho)
    assert_not nacho.following?(nacho)
  end

  test "feed should have the right posts" do
    nacho  = users(:nacho)
    archer = users(:archer)
    lana   = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert nacho.feed.include?(post_following)
    end
    # Self-posts for user with followers
    nacho.microposts.each do |post_self|
      assert nacho.feed.include?(post_self)
      assert_equal nacho.feed.distinct, nacho.feed
    end
    # Posts from non-followed user
    archer.microposts.each do |post_unfollowed|
      assert_not nacho.feed.include?(post_unfollowed)
    end
  end
end
