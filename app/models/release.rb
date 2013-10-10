class Release < ActiveRecord::Base
  attr_accessible :date_time, :metadata_id, :users_id

  belongs_to :metadata
end