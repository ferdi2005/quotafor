class AddRendimentoToBanksAndInsurances < ActiveRecord::Migration[8.1]
  def change
    add_column :banks, :rendimento, :decimal
    add_column :insurances, :rendimento, :decimal
  end
end
