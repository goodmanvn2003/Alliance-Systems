class Metadata < ActiveRecord::Base

  has_many :MetadataAssociation, :dependent => :destroy, :foreign_key => 'srcId'
  has_one :release, :dependent => :destroy, :foreign_key => 'metadata_id'

  belongs_to :Site

  attr_accessible :key, :cat, :value, :mime, :sites_id, :flags

  validates_presence_of :key, :cat, :mime
  ## validates_uniqueness_of :key, :scope => :cat
  # has_paper_trail
end
