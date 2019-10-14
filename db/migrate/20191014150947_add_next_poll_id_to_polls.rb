class AddNextPollIdToPolls < ActiveRecord::Migration[6.0]
  def change
    add_column :polls, :next_poll_id, :integer
    add_column :polls, :previous_poll_id, :integer
  end
end
