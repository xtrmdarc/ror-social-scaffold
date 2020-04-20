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

  has_many :confirmed_friendships, -> { where status: 1 }, class_name: 'Friendship', foreign_key: :requester_id
  has_many :friends, through: :confirmed_friendships, source: :requested

  has_many :pending_friendships, -> { where status: 0 }, class_name: 'Friendship', foreign_key: :requested_id
  has_many :pending_invitations, through: :pending_friendships, source: :requester

  def friends?(user_id)
    res = friends.all.any? do |usr|
      usr.id == user_id
    end
    res
  end

  def send_invitation(user_id)
    @friendship = Friendship.new(requester_id: id, requested_id: user_id)
    @friendship.status = 0
    @friendship.save
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
    Friendship.create(requester_id: id, requested_id: user_id, status: 1)
  end

  def reject_invitation(user_id)
    friendship = requested_friendships.where(requester_id: user_id).first
    friendship.destroy
  end

  def timeline_posts
    user_ids = []
    user_ids.push(id)
    user_ids += friends.all.map(&:id)
    Post.where(user_id: user_ids)
  end
end
