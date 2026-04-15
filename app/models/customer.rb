class Customer < ApplicationRecord
  belongs_to :user
  belongs_to :referred_by_customer, class_name: "Customer", optional: true, inverse_of: :referred_customers

  has_many :appointments, dependent: :destroy
  has_many :contact_calls, dependent: :destroy
  has_many :customer_objectives, dependent: :destroy
  has_many :calendar_events, dependent: :nullify
  has_many :referred_customers, class_name: "Customer", foreign_key: :referred_by_customer_id, dependent: :nullify, inverse_of: :referred_by_customer
  has_many :spouses, dependent: :destroy
  has_many :children, dependent: :destroy
  has_many :customer_expenses, dependent: :destroy
  has_many :banks, dependent: :destroy
  has_many :insurances, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :investments, dependent: :destroy

  accepts_nested_attributes_for :spouses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :children, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :customer_expenses, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :banks, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :insurances, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :properties, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :investments, allow_destroy: true, reject_if: :all_blank

  enum :customer_type, { new_customer: 0, existing_customer: 1, previous_customer: 2 }

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

  def total_income
    [ annual_income, spouses.sum(:annual_income), children.sum(:annual_income) ].compact.sum
  end

  def total_expenses
    customer_expenses.sum(:amount)
  end

  def savings
    total_income - total_expenses
  end
end
