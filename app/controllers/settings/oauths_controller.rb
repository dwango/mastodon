# frozen_string_literal: true
class Settings::OauthsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!

  def show; end

  def update
    current_user.update(oauth_params)
    redirect_to settings_oauth_path, notice: I18n.t('generic.changes_saved_msg')
  end

  def destroy
    current_user.update(provider: nil, uid: nil)
    redirect_to settings_oauth_path, notice: I18n.t('generic.changes_saved_msg')
  end

  private

  def oauth_params
    params.require(:user).permit(:hide_oauth)
  end
end
