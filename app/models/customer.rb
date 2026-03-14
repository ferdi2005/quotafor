class Customer < ApplicationRecord
  belongs_to :user

  has_many :appointments, dependent: :destroy
  has_many :contact_calls, dependent: :destroy
  has_many :customer_objectives, dependent: :destroy
  has_many :customer_timeline_notes, dependent: :destroy
  has_many :calendar_events, dependent: :nullify

  enum :customer_type, { new_customer: 0, existing_customer: 1 }

  validates :first_name, :last_name, :relationship_started_on, :customer_type, presence: true

  scope :active, -> { where(active: true) }
  scope :by_full_name, lambda { |query|
    q = "%#{query.to_s.strip.downcase}%"
    where("LOWER(first_name || ' ' || last_name) LIKE ?", q)
  }
  scope :by_profession, ->(value) { where("LOWER(profession) LIKE ?", "%#{value.to_s.downcase}%") }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def age
    return nil unless birth_date

    now = Time.zone.today
    years = now.year - birth_date.year
    years -= 1 if now.yday < birth_date.yday
    years
  end
end
