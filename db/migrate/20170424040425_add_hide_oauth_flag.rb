class AddHideOauthFlag < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :hide_oauth, :boolean, default: false
    add_index :users, [:provider, :uid, :hide_oauth]
  end
end
