class User < ApplicationRecord
  THEMES = %w[light dark].freeze

  validates :theme_preference, inclusion: { in: THEMES }
  validates :provider, :uid, :email, presence: true
  validates :uid, uniqueness: { scope: :provider }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
    end
  end
end
