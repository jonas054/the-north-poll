class CreateScales < ActiveRecord::Migration[6.0]
  def change
    create_table :scales do |t|
      t.string :list

      t.timestamps
    end

    add_column :polls, :scale_id, :integer
  end
end
