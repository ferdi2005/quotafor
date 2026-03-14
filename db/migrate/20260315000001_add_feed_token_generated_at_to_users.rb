class AddFeedTokenGeneratedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :feed_token_generated_at, :datetime
  end
end
