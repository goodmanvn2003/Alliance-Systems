require 'spec_helper'

describe HomeController do
  render_views

  before :all do
    # should create a host of model data
    @page_mock = create(:index)
    @template_mock = create(:sample)
    @testpl_mock = create(:testpl)
    @anotherpl_mock = create(:anotherpl)
    @even_pl_mock = create(:even)
    @odd_pl_mock = create(:odd)
    @rscript_rb_mock = create(:rscript)
    @meta_mock = create(:smeta)
    @js_mock = create(:sjs)
    @css_mock = create(:scss)
    @app_mock = create(:sapp)
    @index_sample_mock = create(:index_sample)
    @sample_meta_mock = create(:sample_meta)
    @sample_js_mock = create(:sample_js)
    @sample_css_mock = create(:sample_css) 
    @testpl_podio_mock = create(:testpl_podio)
    @anotherpl_podio_mock = create(:anotherpl_podio)
    @current_locale_mock = create(:currentLocale)
  end
  
  after :all do
  	@page_mock.destroy
    @template_mock.destroy
    @testpl_mock.destroy
    @anotherpl_mock.destroy
    @even_pl_mock.destroy
    @odd_pl_mock.destroy
    @rscript_rb_mock.destroy
    @meta_mock.destroy
    @js_mock.destroy
    @css_mock.destroy
    @app_mock.destroy
    @current_locale_mock.destroy
  end

  describe 'GET #display' do
    it "should render mocked page with advanced tags" do

      controller.stub(:ensure_login).and_return true
      controller.stub(:persist_external_database_connection).and_return true

      if (defined?(AbstractApplication))
        AbstractApplication.stub(:app_exists?).and_return true
      end

      TMetadata = Struct.new(:value)
      Metadata.should_receive(:first).at_least(:once).and_return TMetadata.new('{"name":"app name", "description":"a description"}')
      controller.should_receive(:parse_placeholders).at_least(:once).and_return @template_mock.value
      controller.should_receive(:find_site).at_least(:once).and_return 1
      
      get :display, {:tpl => 'index'}
      response.should contain('Hello Template')
    end
  end

  describe 'GET #serve' do
    it "should allow user to download file" do
      Dir.stub(:exists?).and_return true
      File.stub(:exists?).and_return true
      controller.should_receive(:send_file).and_return double()
      controller.stub(:render)

      get :serve, {:filename => 'somefile.txt', :app => '123456'}

      response.should be_success
    end

    it "should not serve file if folder doesn't exist" do
      Dir.stub(:exists?).and_return false

      expect { get :serve, {:filename => 'somefile.txt'} }.to raise_error
    end

    it "should not serve file if file doesn't exist" do
      Dir.stub(:exists?).and_return true
      File.stub(:exists?).and_return false

      expect { get :serve, {:filename => 'somefile.txt'} }.to raise_error
    end
  end

  describe 'Private' do

  end
end
