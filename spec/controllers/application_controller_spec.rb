require 'spec_helper'

describe ApplicationController do
	
	before do
		#controller.stub...
	end
	
	it "should show 500 error on runtime exception" do 
		@controller = ApplicationController.new
		expect { @controller.send(:show_error_500, exception = StandardError) }.to raise_error
	end

end