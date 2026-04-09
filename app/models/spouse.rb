class Spouse < ApplicationRecord
  belongs_to :customer

  validates :first_name, :last_name, presence: true

  def age
    return nil unless birth_date

    now = Time.zone.today
    years = now.year - birth_date.year
    years -= 1 if now.yday < birth_date.yday
    years
  end
end
