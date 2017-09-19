# frozen_string_literal: true

class Settings::ProfileEmojisController < ApplicationController
  include ObfuscateFilename

  layout 'admin'

  before_action :authenticate_user!
  before_action :set_account

  obfuscate_filename [:account, :profile_emoji]

  def show; end

  def update
    if @account.update(account_params)
      redirect_to settings_profile_emoji_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :show
    end
  end

  private

  def account_params
    if params.has_key? :account
      params.require(:account).permit(:profile_emoji)
    end
  end

  def set_account
    @account = current_user.account
  end
end
