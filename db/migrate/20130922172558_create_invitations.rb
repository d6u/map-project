class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.references :user   , index: true
      t.references :project, index: true
      t.string     :code
      t.string     :email
      t.text       :message
      t.integer    :invitation_type
      # type: 0 link, 1 email, 2 facebook, 3 twitter
      t.integer    :status, default: 0

      t.timestamps
    end
    add_index :invitations, :code
  end
end
