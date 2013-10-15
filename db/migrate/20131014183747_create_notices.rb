class CreateNotices < ActiveRecord::Migration
  def change
    create_table :notices do |t|
      t.references :sender  , index: true, null: false
      t.references :receiver, index: true, null: false
      t.references :project , index: true
      t.integer    :notice_type          , null: false
      t.json       :content

      t.timestamps
    end
  end
end
