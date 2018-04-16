# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  include Authorization
  respond_to :json

  before_action :set_custom_emoji, only: [:destroy]

  def index
    render json: CustomEmoji.local.where(disabled: false), each_serializer: REST::CustomEmojiSerializer
  end

  def create
    authorize :custom_emoji, :create?

    @custom_emoji = CustomEmoji.create!(resource_params)
    render json: @custom_emoji, serializer: REST::CustomEmojiSerializer
  end

  def destroy
    authorize :custom_emoji, :destroy?

    @custom_emoji.destroy!
    render_empty
  end

  private

  def resource_params
    params.require(:custom_emoji).permit(:shortcode, :image, :visible_in_picker)
  end

  def set_custom_emoji
    @custom_emoji = CustomEmoji.local.find_by(shortcode: params[:id])
  end
end
