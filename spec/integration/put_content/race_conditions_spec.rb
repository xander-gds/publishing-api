require "rails_helper"

RSpec.describe V2::PutContentCommand do
  include_context "PutContent call"

  describe "race conditions", skip_cleaning: true do
    let(:document) do
      create(
        :document,
        content_id: content_id,
        stale_lock_version: 5,
      )
    end

    let!(:edition) do
      create(
        :live_edition,
        document: document,
        user_facing_version: 5,
        first_published_at: 1.year.ago,
        base_path: base_path,
      )
    end

    after do
      DatabaseCleaner.clean_with :truncation
    end

    it "copes with race conditions" do
      described_class.call(payload)
      V2::PublishCommand.call({ content_id: content_id, update_type: "minor" })

      thread1 = Thread.new { described_class.call(payload) }
      thread2 = Thread.new { described_class.call(payload) }
      thread1.join
      thread2.join

      expect(Edition.all.pluck(:state)).to match_array(%w[superseded published draft])
    end
  end
end
