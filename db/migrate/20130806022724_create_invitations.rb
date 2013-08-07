class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :code
      t.references :user, index: true
      t.references :project, index: true

      t.timestamps
    end
    add_index :invitations, :code
  end
end
