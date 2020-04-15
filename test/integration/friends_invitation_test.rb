require 'test_helper'

class FriendsInvitationTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com',
                     password: 'foobar', password_confirmation: 'foobar')
    @friend = User.new(name: 'Example Friend', email: 'friend@example.com',
                       password: 'foobar', password_confirmation: 'foobar')
  end

  test 'friend should have received invitation when user send sent_invitation' do
    @user.save
    @friend.save
    post '/users/sign_in', params: { user: { email: @user.email,
                                             password: @user.password } }

    get '/sent_invitation/' + @friend.id.to_s
    assert @friend.invitation_received?(@user.id)
  end

  test 'friend can accept invitation when user send sent_invitation' do
    @user.save
    @friend.save
    post '/users/sign_in', params: { user: { email: @user.email,
                                             password: @user.password } }

    get '/sent_invitation/' + @friend.id.to_s
    @friend.accept_invitation(@user.id)
    assert @friend.friends?(@user.id)
    assert @user.friends?(@friend.id)
  end

  test 'friend can reject invitation when user send sent_invitation' do
    @user.save
    @friend.save
    post '/users/sign_in', params: { user: { email: @user.email,
                                             password: @user.password } }

    get '/sent_invitation/' + @friend.id.to_s
    @friend.reject_invitation(@user.id)
    assert_not @friend.friends?(@user.id)
    assert_not @user.friends?(@friend.id)
  end
end
