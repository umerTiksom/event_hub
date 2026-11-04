
# frozen_string_literal: true

class Event < ApplicationRecord
   belongs_to :category
   belongs_to :user
   has_many :registrations, dependent: :destroy

   # Search events by name or description
   def self.search_events(events, search)
      return events unless search.present?

      search_term = "%#{sanitize_sql_like(search)}%"

      events.where(
        "events.name ILIKE :term OR events.description ILIKE :term",
        term: search_term
      )
   end

   # Filter events by category
   def self.filter_by_category(events, category)
      return events unless category.present? && category != "All"

      events.joins(:category)
            .where(categories: { name: category })
   end

   # Filter events by location
   def self.filter_by_location(events, location)
      return events unless location.present?

      location_term = "%#{sanitize_sql_like(location)}%"

      events.where(
        "events.location ILIKE ?",
        location_term
      )
   end

   # Apply all filters
   def self.filter_events(events, search: nil, category: nil, location: nil)
      events = events.includes(:category)

      events = search_events(events, search)
      events = filter_by_category(events, category)
      events = filter_by_location(events, location)

      events
   end

   # Paginate events
   def self.paginate_events(events, page: 1, per_page: 3)
      page = page.to_i
      page = 1 if page < 1

      events.paginate(
        page: page,
        per_page: per_page
      )
   end
end
