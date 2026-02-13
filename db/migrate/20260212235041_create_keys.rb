class CreateKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :keys do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
