class Gram < ApplicationRecord
  belongs_to :user
  mount_uploader :image, ImageUploader
  validates :message, presence: true
  validates :image, presence: true

end
