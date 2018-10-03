class RenameBillColumns < ActiveRecord::Migration
	def change
		change_table :users do |t|
			t.rename :q1_bill, :q1_consumption
			t.rename :q2_bill, :q2_consumption
			t.rename :q3_bill, :q3_consumption
			t.rename :q4_bill, :q4_consumption
		end
	end
end
