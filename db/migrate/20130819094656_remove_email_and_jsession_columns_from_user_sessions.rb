class RemoveEmailAndJsessionColumnsFromUserSessions < ActiveRecord::Migration
  def up
    remove_column :user_sessions, :j_session_id
    remove_column :user_sessions, :email
  end

  def down
    add_column :user_sessions, :j_session_id, :string
    add_column :user_sessions, :email, :string
  end
end
