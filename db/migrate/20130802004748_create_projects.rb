class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string     :title
      t.text       :notes
      t.references :owner, index: true

      t.timestamps
    end
    add_index :projects, :title
  end
end
