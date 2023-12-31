class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  #中間テーブルの記載↑

  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_relationships, source: :follower

  has_one_attached :profile_image

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }

  def following?(user)
    followings.include?(user)
  end

  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  def follow(user_id)
    relationships.create(followed_id: user_id)
  end

  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end

  # 検索方法分岐 (nameは検索対象であるusersテーブル内のカラム名)

  def self.looks(search, word)

    if search == "perfect_match"
      @user = User.where("name LIKE?", "#{word}")#完全一致
    elsif search == "forward_match"
      @user = User.where("name LIKE?", "#{word}%")#前方一致
    elsif search == "backward_match"
      @user = User.where("name LIKE?", "%#{word}")#後方一致
    elsif search == "partial_match"
      @user = User.where("name LIKE?", "%#{word}%")#部分一致
    else
      @user = User.all
    end

  end

end

