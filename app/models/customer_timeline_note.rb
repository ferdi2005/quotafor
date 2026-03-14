class CustomerTimelineNote < ApplicationRecord
  belongs_to :customer
  belongs_to :user

  enum :category, {
    call_note: 0,
    interview_summary: 1,
    visit_summary: 2,
    personal_update: 3
  }

  validates :happened_at, :category, :content, presence: true
end
