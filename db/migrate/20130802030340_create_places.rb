class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.text       :notes
      t.string     :name
      t.text       :address
      t.string     :coord
      t.integer    :order
      t.references :project, index: true

      t.timestamps
    end
  end
end
