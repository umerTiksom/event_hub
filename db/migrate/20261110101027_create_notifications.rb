class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      # Notification recipient (event organizer)
      t.references :user, null: false, foreign_key: true

      # Related event
      t.references :event, null: false, foreign_key: true

      # User who triggered the notification
      t.references :actor,
                   null: false,
                   foreign_key: { to_table: :users }

      # Notification action
      t.string :action, null: false

      # Null means unread; timestamp means read
      t.datetime :read_at

      t.timestamps
    end
  end
end