class PutPublishIntentCommand < BaseCommand
  def call
    PathReservation.reserve_base_path!(base_path, payload[:publishing_app])

    if downstream
      payload = publish_intent
      ContentStoreAdapter.put_publish_intent(base_path, payload)
    end

    SuccessCommand.new(payload)
  end

private

  def publish_intent
    payload.except(:base_path).deep_symbolize_keys
  end

  def base_path
    payload.fetch(:base_path)
  end
end
