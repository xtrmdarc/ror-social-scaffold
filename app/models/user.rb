class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :requester_friendships, foreign_key: :requester_id, class_name: 'Friendship'
  has_many :requested_friendships, foreign_key: :requested_id, class_name: 'Friendship'

  def friends
    friends = requester_friendships.map do |fri|
      fri.requested if fri.status == 1
    end

    friends += requested_friendships.map do |fri|
      fri.requester if fri.status == 1
    end
    friends.compact
  end

  def friends?(user_id)
    res = friends.any? do |usr|
      usr.id == user_id
    end
    res
  end

  def send_invitation(user_id)
    @friendship = Friendship.new(requester_id: id, requested_id: user_id)
    @friendship.status = 0
    @friendship.save
  end

  def pending_invitations
    invitations = requested_friendships.map do |usr|
      usr.requester if usr.status.zero?
    end
    invitations.compact
  end

  def invitation_sent?(user_id)
    friendship = requester_friendships.where(requested_id: user_id).first
    true if friendship && friendship.status.zero?
  end

  def invitation_received?(user_id)
    friendship = requested_friendships.where(requester_id: user_id).first
    true if friendship && friendship.status.zero?
  end

  def accept_invitation(user_id)
    friendship = requested_friendships.where(requester_id: user_id).first
    friendship.status = 1
    friendship.save
  end

  def reject_invitation(user_id)
    friendship = requested_friendships.where(requester_id: user_id).first
    friendship.destroy
  end

  def timeline_posts
    user_ids = []
    user_ids.push(id)
    user_ids += friends.map(&:id)
    Post.where(user_id: user_ids)
  end
end
