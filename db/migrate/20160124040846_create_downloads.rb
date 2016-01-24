class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.text :user_id
      t.text :torrent_url
      t.text :name
      t.text :status

      t.datetime :downloaded_at
      t.timestamps null: false
    end
  end
end
