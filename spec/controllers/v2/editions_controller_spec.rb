require "rails_helper"

RSpec.describe V2::EditionsController do
  describe "index" do
    before do
      Timecop.freeze("2017-01-01 09:00:00") do
        50.times do |index|
          FactoryGirl.create(
            :draft_edition,
            id: index + 1,
            document: FactoryGirl.create(:document, locale: "fr"),
            base_path: "/content#{index + 1}",
          )
        end

        50.times do |index|
          FactoryGirl.create(
            :live_edition,
            id: index + 51,
            document: FactoryGirl.create(:document),
            base_path: "/content#{index + 51}",
          )
        end

        50.times do |index|
          FactoryGirl.create(
            :unpublished_edition,
            id: index + 101,
            document: FactoryGirl.create(:document),
            base_path: "/content#{index + 101}",
            publishing_app: "test",
          )
        end
      end
    end

    context "all editions" do
      it "returns the correct list for the first page" do
        get :index
        expect(parsed_response["results"].count).to eq(100)
        expect(parsed_response["links"]).to eq([
          { "href" => "http://test.host/v2/editions?page=2017-01-01T09%3A00%3A00Z%2C100", "rel" => "next" },
        ])
      end

      it "returns the correct list for the second page" do
        get :index, params: { page: "2017-01-01T09:00:00Z,100" }
        expect(parsed_response["results"].count).to eq(50)
        expect(parsed_response["links"]).to eq([
          { "href" => "http://test.host/v2/editions?page=2017-01-01T09%3A00%3A00Z%2C150", "rel" => "next" },
        ])
      end

      context "with a custom order" do
        it "returns the results in the expected order" do
          get :index, params: { key: "-updated_at,id" }
          expect(parsed_response["results"].first["base_path"]).to eq("/content150")
          expect(parsed_response["links"]).to eq([
            { "href" => "http://test.host/v2/editions?key=-updated_at%2Cid&page=2017-01-01T09%3A00%3A00Z%2C51", "rel" => "next" },
          ])
        end
      end

      context "with a custom key" do
        it "returns the correct next page link" do
          get :index, params: { key: "id", page: 10 }
          expect(parsed_response["links"]).to eq([
            { "href" => "http://test.host/v2/editions?key=id&page=110", "rel" => "next" },
          ])
        end
      end

      context "with a custom pagination count" do
        it "returns the correct number of results" do
          get :index, params: { count: 25 }
          expect(parsed_response["results"].count).to eq(25)
          expect(parsed_response["links"]).to eq([
            { "href" => "http://test.host/v2/editions?count=25&page=2017-01-01T09%3A00%3A00Z%2C25", "rel" => "next" },
          ])
        end
      end
    end

    context "filtered by state" do
      it "returns only published editions" do
        get :index, params: { states: "published" }
        expect(parsed_response["results"].count).to eq(50)
        expect(parsed_response["links"]).to eq([
          { "href" => "http://test.host/v2/editions?states=published&page=2017-01-01T09%3A00%3A00Z%2C100", "rel" => "next" },
        ])
      end
    end

    context "filtered by locale" do
      it "returns only published editions" do
        get :index, params: { locale: "fr" }
        expect(parsed_response["results"].count).to eq(50)
        expect(parsed_response["links"]).to eq([
          { "href" => "http://test.host/v2/editions?locale=fr&page=2017-01-01T09%3A00%3A00Z%2C50", "rel" => "next" },
        ])
      end
    end

    context "filtered by publishing app" do
      it "returns only published editions" do
        get :index, params: { publishing_app: "test" }
        expect(parsed_response["results"].count).to eq(50)
        expect(parsed_response["links"]).to eq([
          { "href" => "http://test.host/v2/editions?publishing_app=test&page=2017-01-01T09%3A00%3A00Z%2C150", "rel" => "next" },
        ])
      end
    end

    context "outputting custom fields" do
      it "returns only the fields specified" do
        get :index, params: { fields: %w(content_id publishing_app) }
        expect(parsed_response["results"].first.keys)
          .to eq(%w(publishing_app content_id))
      end
    end
  end
end
