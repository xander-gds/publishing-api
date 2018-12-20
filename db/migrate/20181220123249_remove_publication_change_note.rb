# Remove a public change note (dated 19 December 2018) for publication
# Ticket: https://govuk.zendesk.com/agent/tickets/3539796

class RemovePublicationChangeNote < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    # Find change notes
    document = Document.where(content_id: "be17ca4b-7e61-4e2c-a08d-1baf3b256cf0").first
    if document.present?
      editions = document.editions
      change_notes = editions.map(&:change_note).compact

      change_notes.select!{ |change_note| change_note.note == "Updated information will be provided in January 2019."}

      # Get rid of change notes
      change_notes.map(&:destroy)

      editions_with_change_notes = change_notes.map(&:edition_id)

      editions_with_change_notes.each do |edition_id|
        edition = Edition.find(edition_id)
        edition_details = edition.details
        edition_details.delete(:change_history)
        edition.update!(details: edition_details)
      end

      puts "The editions that need to be represented downstream are: #{editions_with_change_notes}"

      if Rails.env.production?
        Commands::V2::RepresentDownstream.new.call(editions_with_change_notes)
      end
    end
  end

  def down
    # This migration is not reversible
  end
end
