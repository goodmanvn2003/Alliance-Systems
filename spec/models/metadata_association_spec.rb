require 'spec_helper'

describe MetadataAssociation do
  it { should validate_presence_of :destId }
  it { should validate_presence_of :srcId }
end
