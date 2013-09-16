class CreateProjectParticipations < ActiveRecord::Migration
  def change
    create_table :project_participations do |t|
      t.references :project, index: true
      t.references :user   , index: true
      t.integer    :status

      t.timestamps
    end
    add_index :project_participations, [:project_id, :user_id], :unique => true
  end
end
