class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.string :voter
      t.string :content
      t.integer :poll_id

      t.timestamps
    end
  end
end
