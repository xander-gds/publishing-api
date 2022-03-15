module V2
  class LinkChangesController < ApplicationController
    def index
      render json: GetLinkChangesQuery.new(params).as_hash
    end
  end
end
