class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :user   , index: true
      t.references :project, index: true
      t.string     :code
      t.string     :email
      t.text       :message

      t.timestamps
    end
    add_index :invitations, :code
  end
end
