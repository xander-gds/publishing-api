class PublishIntentsController < ApplicationController
  def show
    render json: GetPublishIntentQuery.call(base_path)
  end

  def create_or_update
    response = PutPublishIntentCommand.call(edition)
    render status: response.code, json: response
  end

  def destroy
    response = DeletePublishIntentCommand.call({ base_path: base_path })
    render status: response.code, json: response
  end

private

  def edition
    payload.merge(base_path: base_path)
  end
end
