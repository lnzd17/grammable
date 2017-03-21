class Gram < ApplicationRecord
  belongs_to :user
  has_many :comments
  mount_uploader :image, ImageUploader
  validates :message, presence: true
  validates :image, presence: true

end
