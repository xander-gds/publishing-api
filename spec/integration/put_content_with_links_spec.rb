require "rails_helper"

RSpec.describe Commands::V2::PutContent do
  describe "call" do
    let(:content_id) { SecureRandom.uuid }
    let(:base_path) { "/vat-rates" }
    let(:locale) { "en" }

    let(:change_note) { { note: "Info", public_timestamp: Time.now.utc.to_s } }

    let(:payload) do
      {
        content_id: content_id,
        base_path: base_path,
        update_type: "major",
        title: "Some Title",
        publishing_app: "publisher",
        rendering_app: "frontend",
        document_type: "nonexistent-schema",
        schema_name: "nonexistent-schema",
        locale: locale,
        routes: [{ path: base_path, type: "exact" }],
        redirects: [],
        phase: "beta",
        change_note: change_note
      }
    end


    context "when the 'links' parameter is provided" do
      before do
        payload.merge!(links: { users: [link] })
      end

      context "invalid UUID" do
        let!(:link) { "not a UUID" }

        it "should raise a validation error" do
          expect {
            described_class.call(payload)
          }.to raise_error(CommandError, /UUID/)
        end
      end

      context "valid UUID" do
        let(:document) { FactoryGirl.create(:document) }
        let!(:link) { document.content_id }

        it "should create a link" do
          expect {
            described_class.call(payload)
          }.to change(Link, :count).by(1)

          expect(Link.find_by(target_content_id: document.content_id)).to be
        end
      end

      context "existing links" do
        let(:document) { FactoryGirl.create(:document, content_id: content_id) }
        let(:content_id) { SecureRandom.uuid }
        let(:link) { SecureRandom.uuid }

        before do
          edition.links.create!(target_content_id: document.content_id, link_type: "random")
        end

        context "draft edition" do
          let(:edition) { FactoryGirl.create(:draft_edition, document: document, base_path: base_path) }

          it "passes the old link to dependency resolution" do
            expect(DownstreamDraftWorker).to receive(:perform_async_in_queue).with(
              "downstream_high",
              a_hash_including(orphaned_content_ids: [content_id])
            )
            described_class.call(payload)
          end
        end

        context "published edition" do
          let(:edition) { FactoryGirl.create(:live_edition, document: document, base_path: base_path) }

          it "passes the old link to dependency resolution" do
            expect(DownstreamDraftWorker).to receive(:perform_async_in_queue).with(
              "downstream_high",
              a_hash_including(orphaned_content_ids: [content_id])
            )
            described_class.call(payload)
          end
        end
      end
    end
  end
end
