require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test 'the truth' do
  #   assert true
  # end
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com',
                     password: 'foobar', password_confirmation: 'foobar')
    @friend = User.new(name: 'Example Friend', email: 'friend@example.com',
                       password: 'foobar', password_confirmation: 'foobar')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = ' '
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = ' '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lower-case' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'friend should be added to users friendlist' do
    @friend.save
    @user.save
    Friendship.create(requested_id: @friend.id, requester_id: @user.id, status: 1)
    assert @user.friends?(@friend.id)
  end

  test 'user should be added to friend friendlist' do
    @friend.save
    @user.save
    Friendship.create(requested_id: @friend.id, requester_id: @user.id, status: 1)
    assert @friend.friends?(@user.id)
  end

  test 'friend should be added to users friendlist when user accept invitation' do
    @friend.save
    @user.save
    Friendship.create(requested_id: @user.id, requester_id: @friend.id, status: 0)
    @user.accept_invitation(@friend.id)
    assert @user.friends?(@friend.id)
  end

  test 'user should be added to friend friendlist when user accept invitation' do
    @friend.save
    @user.save
    Friendship.create(requested_id: @user.id, requester_id: @friend.id, status: 0)
    @user.accept_invitation(@friend.id)
    assert @friend.friends?(@user.id)
  end

  test 'friend should not be added to users friendlist when user reject' do
    @friend.save
    @user.save
    Friendship.create(requester_id: @friend.id, requested_id: @user.id, status: 0)
    @user.reject_invitation(@friend.id)
    assert_not @user.friends?(@friend.id)
  end

  test 'user should not be added to friend friendlist when friend reject' do
    @friend.save
    @user.save
    Friendship.create(requested_id: @friend.id, requester_id: @user.id, status: 0)
    @friend.reject_invitation(@user.id)
    assert_not @friend.friends?(@user.id)
  end
end
