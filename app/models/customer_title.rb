class CustomerTitle < ApplicationRecord
  belongs_to :customer

  validates :title_type, presence: true
end
