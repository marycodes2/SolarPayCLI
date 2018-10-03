class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :periods do |t|
      t.string :name
      t.float :price
      t.integer :region_id
    end
  end
end
