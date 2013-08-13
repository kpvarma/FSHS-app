class CreateUserSessions < ActiveRecord::Migration
  
  def change
    create_table(:user_sessions) do |t|
      t.string :email
      t.string :auth_token
      t.string :j_session_id
      t.string :hs_pid
      t.string :hs_uid
      t.string :hs_auth_token
      t.string :fs_auth_token
      t.timestamps
    end
  end

end
