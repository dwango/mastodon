# frozen_string_literal: true

class Api::V1::FavouriteTagsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action -> { doorkeeper_authorize! :write }, only: [:create, :destroy]
  before_action :require_user!
  before_action :set_favourite_tag, only: [:destroy]

  respond_to :json

  def index
    @favourite_tags = current_account.favourite_tags.includes(:tag)
  end

  def create
    name = tag_params[:name].gsub(/\A#/, '')
    tag = Tag.find_or_initialize_by(name: name)
    @favourite_tag = FavouriteTag.new(account: current_account, tag: tag)
    render json: invalid_name_error, status: 400 unless @favourite_tag.save
  end

  def destroy
    @favourite_tag.destroy
    render_empty
  end

  private

  def tag_params
    params.permit(:name)
  end

  def set_favourite_tag
    @favourite_tag = current_account.favourite_tags.find(params[:id])
  end

  def invalid_name_error
    { error: 'Tag name is invalid' }
  end
end
