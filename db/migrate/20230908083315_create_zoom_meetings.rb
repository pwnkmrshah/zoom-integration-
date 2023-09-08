class CreateZoomMeetings < ActiveRecord::Migration[7.0]
  def change
    create_table :zoom_meetings do |t|
      t.text :access_token
      t.text :refresh_access_token

      t.timestamps
    end
  end
end
