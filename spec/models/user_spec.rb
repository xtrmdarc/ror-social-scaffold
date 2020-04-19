require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  
  let(:user) { User.new(name: 'Example User', email: 'user@example.com',
                        password: 'foobar', password_confirmation: 'foobar') }
  let(:friend) { User.new(name: 'Example Friend', email: 'friend@example.com',
                          password: 'foobar', password_confirmation: 'foobar') }

  describe 'validates user attributes' do
    it 'validates if the user is valid' do
      expect(user.valid?).to eql(true)
    end
    it 'validates if the user name is present' do
      user.name = ' '
      expect(user.valid?).not_to eql(true)
    end
    it 'validates if the email is present' do
      user.email = ' '
      expect(user.valid?).not_to eql(true)
    end
    it 'validates if the name is not too long' do
      user.name = 'a' * 51
      expect(user.valid?).not_to eql(true)
    end
    it 'validates if the email addresses are unique' do
      duplicate_user = user.dup
      duplicate_user.email = user.email.upcase
      user.save
      expect(duplicate_user.valid?).not_to eql(true)
    end
    it 'validates if the email addresses are saved as lower-case' do
      mixed_case_email = 'Foo@ExAMPle.CoM'
      user.email = mixed_case_email
      user.save
      expect(mixed_case_email.downcase == user.reload.email).to eql(true)
    end
    it 'validates if password is present (nonblank)' do
      user.password = user.password_confirmation = ' ' * 6
      expect(user.valid?).not_to eql(true)
    end
    it 'validates if password has a minimum length' do
      user.password = user.password_confirmation = 'a' * 5
      expect(user.valid?).not_to eql(true)
    end
  end

  describe 'validates friendship associations' do
    it 'validates if friend is added to users friendlist' do
      friend.save
      user.save
      Friendship.create(requested_id: friend.id, requester_id: user.id, status: 1)
      expect(user.friends?(friend.id)).to eql(true)
    end
    it 'validates if user is added to friend friendlist' do
      friend.save
      user.save
      friend.send_invitation(user.id)
      user.accept_invitation(friend.id)
      expect(friend.friends?(user.id)).to eql(true)
    end
    it 'validates if friend is added to users friendlist when user accept invitation' do
      friend.save
      user.save
      friend.send_invitation(user.id)
      user.accept_invitation(friend.id)
      expect(user.friends?(friend.id)).to eql(true)
    end
    it 'validates if user is added to friend friendlist when user accept invitation' do
      friend.save
      user.save
      Friendship.create(requested_id: user.id, requester_id: friend.id, status: 0)
      user.accept_invitation(friend.id)
      expect(user.friends?(friend.id)).to eql(true)
    end
    it 'validates if friend is not added to users friendlist when user reject' do
      friend.save
      user.save
      Friendship.create(requested_id: user.id, requester_id: friend.id, status: 0)
      user.reject_invitation(friend.id)
      expect(user.friends?(friend.id)).not_to eql(true)
    end
    it 'validates if user is not added to friend friendlist when friend reject' do
      friend.save
      user.save
      Friendship.create(requested_id: friend.id, requester_id: user.id, status: 0)
      friend.reject_invitation(user.id)
      expect(friend.friends?(user.id)).not_to eql(true)
    end
  end
end
