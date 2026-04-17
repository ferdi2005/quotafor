class Insurance < ApplicationRecord
  belongs_to :customer

  enum :reason,
       {
         rendita: "rendita",
         capitale: "capitale",
         misto: "misto"
       },
       prefix: true

  enum :investment_frequency,
       {
         unico: 0,
         mensile: 1,
         annuale: 2
       },
       prefix: true

  validates :reason, presence: true
  validates :objective, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
