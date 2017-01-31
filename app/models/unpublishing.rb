class Unpublishing < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :edition

  VALID_TYPES = %w(
    gone
    vanish
    redirect
    substitute
    withdrawal
  ).freeze

  validates :edition, presence: true, uniqueness: true
  validates :type, presence: true, inclusion: { in: VALID_TYPES }
  validates :explanation, presence: true, if: :withdrawal?
  validates :alternative_path, presence: true, if: :redirect?
  validates_with UnpublishingRedirectValidator

  def withdrawal?
    type == "withdrawal"
  end

  def redirect?
    type == "redirect"
  end

  def self.is_substitute?(edition)
    where(edition: edition).pluck(:type).first == "substitute"
  end

  def self.join_editions(edition_scope)
    edition_scope.joins(
      "LEFT OUTER JOIN unpublishings ON editions.id = unpublishings.edition_id"
    )
  end
end
