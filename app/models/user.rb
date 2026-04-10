class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :time_zone, presence: true
  validates :calendar_feed_token, presence: true, uniqueness: true

  has_many :customers, dependent: :destroy
  has_many :customer_objectives, through: :customers
  has_many :appointments, dependent: :destroy
  has_many :contact_calls, dependent: :destroy
  has_many :recurring_activities, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :in_app_notifications, dependent: :destroy

  before_validation :ensure_calendar_feed_token

  def regenerate_feed_token!
    update!(
      calendar_feed_token: SecureRandom.hex(24),
      feed_token_generated_at: Time.current
    )
  end

  def refresh_rfa_expected!
    update!(rfa_expected: customer_objectives.sum(Arel.sql("COALESCE(invested_resources, 0) - COALESCE(diminished_resources, 0)")))
  end

  private

  def ensure_calendar_feed_token
    if calendar_feed_token.blank?
      self.calendar_feed_token = SecureRandom.hex(24)
      self.feed_token_generated_at = Time.current
    end
  end
end
