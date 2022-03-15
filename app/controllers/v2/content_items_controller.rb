module V2
  class ContentItemsController < ApplicationController
    def index
      pagination = Pagination.new(query_params)

      results = GetContentCollectionQuery.new(
        document_types: document_types,
        fields: query_params[:fields],
        filters: filters,
        pagination: pagination,
        search_query: query_params.fetch("q", ""),
        search_in: query_params[:search_in],
      )

      render json: Presenters::ResultsPresenter.new(results, pagination, request.original_url).present
    end

    def linkables
      render json: GetLinkablesQuery.new(
        document_type: query_params.fetch(:document_type),
      ).call
    end

    def show
      render json: GetContentQuery.call(
        path_params[:content_id],
        query_params[:locale],
        version: query_params[:version],
        include_warnings: true,
      )
    end

    def import
      response = V2::ImportCommand.call(
        edition.merge(locale: query_params[:locale]),
      )
      render status: response.code, json: response
    end

    def put_content
      response = V2::PutContentCommand.call(edition)
      render status: response.code, json: response
    end

    def publish
      response = V2::PublishCommand.call(edition)
      render status: response.code, json: response
    end

    def republish
      response = V2::RepublishCommand.call(edition)
      render status: response.code, json: response
    end

    def unpublish
      response = V2::UnpublishCommand.call(edition)
      render status: response.code, json: response
    end

    def discard_draft
      response = V2::DiscardDraftCommand.call(edition)
      render status: response.code, json: response
    end

  private

    def edition
      payload.merge(content_id: path_params[:content_id])
    end

    def publishing_app
      query_params[:publishing_app]
    end

    def states
      query_params[:states]
    end

    def document_types
      query_params[:document_type] || query_params[:content_format] || []
    end

    def filters
      {
        publishing_app: publishing_app,
        locale: query_params[:locale],
        links: link_filters,
        states: Array(states),
      }
    end

    def link_filters
      {}.tap do |hash|
        query_params.each do |k, v|
          hash[k[5..]] = v if k.start_with?("link_")
        end
      end
    end
  end
end
