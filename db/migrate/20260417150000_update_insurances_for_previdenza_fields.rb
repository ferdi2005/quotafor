class UpdateInsurancesForPrevidenzaFields < ActiveRecord::Migration[8.1]
  def change
    change_column :insurances, :reason, :string
    change_column :insurances,
                  :objective,
                  "numeric(12,2) USING NULLIF(regexp_replace(objective, '[^0-9\\.-]', '', 'g'), '')::numeric(12,2)"

    add_column :insurances, :product_name, :string
    add_column :insurances, :company_name, :string
    add_column :insurances, :investment_frequency, :integer
    add_column :insurances, :subscription_date, :date
    add_column :insurances, :expiry_date, :date
  end
end
