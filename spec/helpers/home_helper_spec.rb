require 'spec_helper'

describe HomeHelper do

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
    @currentLocale_mock = create(:currentLocale)
    @languageItem_mock = create(:languageItem)
    @enUs_mock = create(:enUs)
    @languageItemEn_mock = create(:languageItemEn)
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
    @currentLocale_mock.destroy
    @languageItem_mock.destroy
    @enUs_mock.destroy
    @languageItemEn_mock.destroy
  end

  it "can parse script with attributes" do

    helper.parse_scripts_attrs('[[~rscript? &xyz="abc"]]').should_not be_nil

  end

  it "can parse script without attributes" do

    helper.parse_scripts_attrs('[[~rscript]]').should_not be_nil

  end

  it "can parse language items" do

    helper.parse_language_items_attrs('[[@languageItem? &category="label"]]').should_not be_nil

  end

  it "should parse language items" do

    TMetadata = Struct.new(:value)
    controller.request.headers['Accept-Language'] = 'en_US,en;EN'
    Metadata.should_receive(:first).at_least(:once).and_return TMetadata.new('yes')
    helper.parse_language_items('[[@languageItem? &category="label"]]', 1).should_not be_nil

  end

  it "should parse placeholders" do

    helper.should_receive(:process_placeholder).at_least(:once).and_return 'placeholder'
    helper.parse_placeholders(@page_mock, @template_mock.value, 1).should_not be_nil

  end

  it "should parse scripts" do

    helper.parse_scripts("[[~rscript]]", 1).should_not be_nil

  end

  it "should process placeholders" do

    SystemModel.should_receive(:get_list_of_compatible_gems).at_least(:once).and_return []

    helper.process_placeholder("anotherpl", {'mode' => 'single', 'configs' => {'items' => 'title|content'}}, 1).should_not be_nil

    helper.process_placeholder("anotherpl", {'mode' => 'alternate', 'configs' => {'items' => 'title|content', 'tple' => 'even', 'tplo' => 'odd'}},1).should_not be_nil

  end

  it "should load metas" do

    helper.load_meta_tags(@template_mock, Metadata.all,1).should_not be_nil

  end

  it "should load scripts" do

    helper.load_js(@template_mock, Metadata.all,1).should_not be_nil

  end

  it "should load css" do

    helper.load_css(@template_mock, Metadata.all,1).should_not be_nil

  end

end