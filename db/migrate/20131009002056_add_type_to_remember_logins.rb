class AddTypeToRememberLogins < ActiveRecord::Migration
  def change
    change_table :remember_logins do |t|
      t.integer :login_type, null: false
    end
  end
end
