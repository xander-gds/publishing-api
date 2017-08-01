class Action < ActiveRecord::Base
  serialize :edition_diff
  belongs_to :edition, optional: true
  belongs_to :link_set, optional: true
  belongs_to :event

  validate :one_of_edition_link_set
  validates :action, presence: true

  def self.create_put_content_action(updated_draft, locale, event, edition_diff)
    create_publishing_action("PutContent", updated_draft, locale, event, edition_diff: edition_diff)
  end

  def self.create_publish_action(edition, locale, event)
    create_publishing_action("Publish", edition, locale, event)
  end

  def self.create_unpublish_action(edition, unpublishing_type, locale, event)
    action = "Unpublish#{unpublishing_type.camelize}"
    create_publishing_action(action, edition, locale, event)
  end

  def self.create_discard_draft_action(edition, locale, event)
    create_publishing_action("DiscardDraft", edition, locale, event)
  end

  def self.create_publishing_action(action, edition, locale, event, edition_diff: nil)
    create!(
      content_id: edition.document.content_id,
      locale: locale,
      action: action,
      user_uid: event.user_uid,
      edition: edition,
      event: event,
      edition_diff: edition_diff
    )
  end

  def self.create_patch_link_set_action(link_set, event)
    create!(
      content_id: link_set.content_id,
      locale: nil,
      action: "PatchLinkSet",
      user_uid: event.user_uid,
      link_set: link_set,
      event: event,
    )
  end

private

  def one_of_edition_link_set
    if edition_id && link_set_id || edition && link_set
      errors.add(:base, "can not be associated with both an edition and link set")
    end
  end
end
