class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.float :q1_bill
      t.float :q2_bill
      t.float :q3_bill
      t.float :q4_bill
      t.integer :cost_id
      t.integer :region_id
    end
  end
end
