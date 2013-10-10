class MetadataAssociation < ActiveRecord::Base
  belongs_to :Metadata
  attr_accessible :destId, :srcId

  validates_presence_of :destId, :srcId
end
