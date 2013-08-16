class CreateProjectUser < ActiveRecord::Migration
  def change
    create_table :project_user do |t|
      t.references :project, index: true
      t.references :user, index: true
    end
    add_index :project_user, [:project_id, :user_id], :unique => true
  end
end
