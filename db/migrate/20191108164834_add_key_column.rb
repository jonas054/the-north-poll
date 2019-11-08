class AddKeyColumn < ActiveRecord::Migration[6.0]
  def change
    add_column :polls, :key, :string
  end
end
