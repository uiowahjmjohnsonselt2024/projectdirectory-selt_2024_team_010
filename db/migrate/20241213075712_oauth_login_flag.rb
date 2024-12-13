# this flag is necessary to determine if some user account was logged in via oauth.
# without it, if the user created an account normally and then logged in with the github account that email was associated with, they'd be able to log in without password verification or anything.
# could result in nefarious things going on. thwart those...
class OauthLoginFlag < ActiveRecord::Migration
  def up
    add_column :users, :is_oauth, :boolean
  end

  def down
    remove_column :users, :is_oauth
  end
end
