class CreateMeetingDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :meeting_details do |t|
      t.string :uuid
      t.string :host_id
      t.string :host_email
      t.string :topic
      t.text :start_url
      t.string :join_url
      t.string :password

      t.timestamps
    end
  end
end
