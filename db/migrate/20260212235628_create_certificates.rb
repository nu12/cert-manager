class CreateCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :certificates do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :key, null: false, foreign_key: true
      t.references :certificate, null: true, foreign_key: true
      t.string :country
      t.string :state
      t.string :location
      t.string :organization
      t.string :organization_unit
      t.string :common_name
      t.string :name
      t.string :serial
      t.date :expirity_date

      t.timestamps
    end
  end
end
