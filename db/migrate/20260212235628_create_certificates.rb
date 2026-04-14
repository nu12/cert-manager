class CreateCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :certificates do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :key, null: false, foreign_key: true
      t.references :certificate, null: true, foreign_key: true
      t.string :name
      t.datetime :expired_at

      t.timestamps
    end
  end
end
