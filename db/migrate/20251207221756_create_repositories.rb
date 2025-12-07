class CreateRepositories < ActiveRecord::Migration[7.2]
  def change
    create_table :repositories do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :github_id
      t.string :name
      t.string :full_name
      t.string :language
      t.string :clone_url
      t.string :ssh_url

      t.timestamps
    end
  end
end
