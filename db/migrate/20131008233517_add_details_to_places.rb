class AddDetailsToPlaces < ActiveRecord::Migration
  def change
    change_table :places do |t|
      t.text       :reference
      t.references :user, index: true, null: false
    end
  end
end
