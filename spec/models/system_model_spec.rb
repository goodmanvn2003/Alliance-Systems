require 'spec_helper'

describe SystemModel do

  before do

  end

  after do

  end

  it "get a list of compatible gem" do
    if defined?(AlliancePodioPlugin)  || defined?(AllianceDbmsPlugin)
      SystemModel.get_list_of_compatible_gems.should_not be_empty
    else
      SystemModel.get_list_of_compatible_gems.should be_empty
    end
  end

end