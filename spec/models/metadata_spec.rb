require 'spec_helper'

describe Metadata do
  it { should validate_presence_of :key }
  it { should validate_presence_of :cat }
  it { should validate_presence_of :mime }
  it { should have_many(:MetadataAssociation) }

  # it { should validate_uniqueness_of(:key).scoped_to(:cat) }
end
