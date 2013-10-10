require 'spec_helper'
require "#{Rails.root}/lib/loaders_utility.rb"

module LoadersUtility
	describe LoadersUtility do

    before :all do
      @placeholder_mock = build(:even)
    end

		describe ContentLoader do
			
			it "should get current time" do
				obj = ContentLoader.get_time
				obj.should_not be_nil
			end
			
			it "should load contents with valid placeholder" do
        Metadata.should_receive(:find).and_return @placeholder_mock
				obj = ContentLoader.load_items_with_placeholder('even',[
				{'title' => 'one'},
				{'title' => 'two'} ])
				obj.should_not be_empty
			end
			
		end
	end
end