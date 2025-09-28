class Movie < ActiveRecord::Base
  # Returns all distinct rating values present in the DB
  # Used by the view to render one checkbox per rating.
  def self.all_ratings
    select(:rating).distinct.order(:rating).pluck(:rating)
  end

  # Returns an ActiveRecord relation filtered by the given ratings_list.
  # - If ratings_list is nil or empty, return all movies
  def self.with_ratings(ratings_list)
    return all if ratings_list.nil? || ratings_list.empty?
    where(rating: ratings_list)
  end
end
