# coding: utf-8
# frozen_string_literal: true
module EnqueteExtension
  extend ActiveSupport::Concern

  def prepare_status_info
    if enquete_params['isEnquete']
      @enquete_items = enquete_params['enquete_items'].select do |item|
        item.present? && item.length <= 15
      end.slice(0, 4).push('🤔')
      raise Mastodon::ValidationError, 'Enquete needs more than 2 items' if @enquete_items.size < 3

      raise Mastodon::ValidationError, 'Question can\'t be blank' if status_params[:status].blank?
      status_text = build_enquete_status_text(status_params[:status], @enquete_items)
      enquete_json = JSON.generate(question: status_params[:status], items: @enquete_items, type: 'enquete')
    else
      status_text = status_params[:status]
    end

    if request.headers['Idempotency-Key'].present?
      existing_toot = redis.get("idempotency:status:#{current_user.account.id}:#{request.headers['Idempotency-Key']}")
    end
    register_enquete_result = enquete_params['isEnquete'] && !existing_toot

    [status_text, enquete_json, register_enquete_result]
  end

  def register_enquete_result_worker(register_enquete_result)
    if register_enquete_result
      EnqueteResultTootWorker.perform_in(30.seconds, @status.id)
      redis.multi do |multi|
        @enquete_items.each_with_index do |_item, i|
          multi.setex("enquete:status:#{@status.id}:item_index:#{i}", 60, 0)
        end
      end
    end
  end

  def enquete_params
    params.permit(:isEnquete, enquete_items: [])
  end

  def build_enquete_status_text(question, items)
    question_frame = "\n━━━━━━━━━━━━\n"
    status = 'friends.nico アンケート' + question_frame + question + question_frame

    items.each_with_index do |item, i|
      branch_mark = i == items.length - 1 ? '└' : '├'
      status += branch_mark + " #{i + 1}.#{item}\n"
    end
    status
  end

  def redis
    Redis.current
  end
end
