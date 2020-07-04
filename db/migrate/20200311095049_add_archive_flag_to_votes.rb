class AddArchiveFlagToVotes < ActiveRecord::Migration[6.0]
  def change
    add_column :votes, :is_archived, :boolean, null: false, default: false
  end
end
