class NormalizeInvestmentPurposeValues < ActiveRecord::Migration[8.1]
  ALLOWED_PURPOSES = %w[liquidity growth income retirement protection diversification other].freeze

  def up
    allowed = ALLOWED_PURPOSES.map { |value| ActiveRecord::Base.connection.quote(value) }.join(", ")

    execute <<~SQL
      UPDATE investments
      SET purpose = 'other'
      WHERE purpose IS NOT NULL
        AND purpose <> ''
        AND LOWER(purpose) NOT IN (#{allowed});
    SQL

    execute <<~SQL
      UPDATE investments
      SET purpose = LOWER(purpose)
      WHERE purpose IS NOT NULL
        AND purpose <> ''
        AND LOWER(purpose) IN (#{allowed});
    SQL
  end

  def down
    # no-op: data normalization is intentionally irreversible
  end
end
