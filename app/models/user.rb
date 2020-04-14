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
    friends = []
    friends = requester_friendships.map do |fri|
                fri.requested if fri.status ==  1
              end

    friends += requested_friendships.map do |fri|
                 fri.requester if fri.status ==  1
               end
    friends
  end

  def friends?(user_id)
    res = friends.any? do |usr|
            usr.id == user_id
          end
    res
  end
end
