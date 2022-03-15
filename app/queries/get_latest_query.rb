module GetLatestQuery
  class << self
    def call(edition_scope)
      edition_scope.where(id: inner_scope(edition_scope))
    end

    def inner_scope(edition_scope)
      edition_scope
        .reorder(:document_id, ["user_facing_version DESC"] + edition_scope.order_values)
        .select("distinct on(editions.document_id) editions.document_id, editions.id")
        .map(&:id)
    end
  end
end
