module V2
  class ActionsController < ApplicationController
    def create
      response = V2::PostActionCommand.call(action_params)
      render status: response.code, json: response
    end

  private

    def action_params
      payload.merge(content_id: content_id)
    end

    def content_id
      params.fetch(:content_id)
    end
  end
end
