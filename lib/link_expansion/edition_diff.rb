class LinkExpansion::EditionDiff
  attr_reader :current_edition, :version

  def initialize(current_edition, version: nil, previous_edition: nil)
    @current_edition = current_edition
    @previous_edition = previous_edition
    @version = version
  end

  def field_diff
    link_expansion_fields & diff.map(&:first)
  end

  def should_update_dependencies?
    field_diff.present?
  end

private

  def link_expansion_fields
    ExpansionRules.potential_expansion_fields(current_edition.document_type)
  end

  def diff
    hash_diff(
      previous_edition_expanded,
      current_edition_expanded
    )
  end

  def hash_diff(a, b) # rubocop:disable Naming/UncommunicativeMethodParamName
    a.size > b.size ? a.to_a - b.to_a : b.to_a - a.to_a
  end

  def previous_edition_expanded
    return {} if previous_edition.blank?
    ExpansionRules.expand_fields(previous_edition.to_h.deep_symbolize_keys, nil)
  end

  def current_edition_expanded
    ExpansionRules.expand_fields(current_edition.to_h.deep_symbolize_keys, nil)
  end

  def previous_edition
    @previous_edition ||=
      current_edition.document.editions.find_by(
        user_facing_version: previous_user_version
    )
  end

  def previous_user_version
    current_user_version - 1
  end

  def current_user_version
    version || current_edition.user_facing_version
  end
end
