# frozen_string_literal: true
class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  Devise.omniauth_providers.each do |provider|
    define_method(provider) do
      auth = request.env['omniauth.auth']
      if current_user
        current_user.update(provider: auth.provider, uid: auth.uid)
      else
        @user = User.find_by(provider: auth.provider, uid: auth.uid)
        sign_in @user if @user
      end

      if current_user
        redirect_to after_sign_in_path_for(current_user)
      else
        redirect_to new_user_registration_path
      end
    end
  end

  protected

  def after_sign_in_path_for(resource)
    last_url = stored_location_for(:user)

    if home_paths(resource).include?(last_url)
      root_path
    else
      last_url || root_path
    end
  end

  private

  def home_paths(resource)
    paths = [about_path]
    if single_user_mode? && resource.is_a?(User)
      paths << short_account_path(username: resource.account)
    end
    paths
  end
end
