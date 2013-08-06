class CreateProjectUser < ActiveRecord::Migration
  def change
    create_table :project_user do |t|
      t.references :project, index: true
      t.references :user, index: true
    end
  end
end
