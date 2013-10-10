require 'spec_helper'

describe "home/index.html.erb" do

  it "should render the index page" do
    render :template => "home/index.html.erb"
  end

end
