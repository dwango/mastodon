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

  private

  def after_sign_in_path_for(_resource)
    last_url = stored_location_for(:user)
    [about_path].include?(last_url) ? root_path : last_url || root_path
  end
end
