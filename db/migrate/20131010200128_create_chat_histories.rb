class CreateChatHistories < ActiveRecord::Migration
  def change
    create_table :chat_histories do |t|
      t.references :user,    null: false, index: true
      t.references :project, null: false, index: true
      t.integer    :type,    null: false, default: 0
      t.json       :content

      t.timestamps
    end
  end
end
