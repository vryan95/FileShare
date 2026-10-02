class User < ApplicationRecord
  THEMES = %w[light dark].freeze
  PASSWORD_MINIMUM_LENGTH = 12

  # Users without a provider sign in with an email address and password instead of SSO.
  has_secure_password validations: false
  has_many :uploaded_files, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :theme_preference, inclusion: { in: THEMES }
  validates :email, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: :provider?
  validates :email, uniqueness: true, unless: :provider?
  validates :password, presence: true, on: :create, unless: :provider?
  validates :password, length: { minimum: PASSWORD_MINIMUM_LENGTH }, confirmation: true, allow_nil: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
    end
  end
end
