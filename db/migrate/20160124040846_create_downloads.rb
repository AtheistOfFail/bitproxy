class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.text :user_id
      t.text :torrent_url
      t.text :reference

      t.timestamps null: false
    end
  end
end
