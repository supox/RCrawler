require 'spec_helper'

describe "settings/show" do
  before(:each) do
    @setting = assign(:setting, stub_model(Setting,
      :rap_username => "Rap Username",
      :rap_password => "Rap Password",
      :price_list_extra_discount => 1,
      :price_list_min_number_of_results_to_display => 2,
      :start_xvfb => false,
      :ranges_size_start => "9.99",
      :ranges_size_end => "9.99",
      :ranges_cut => "",
      :ranges_polish => "",
      :ranges_sym => "",
      :ranges_clarity => "",
      :ranges_color_start => "Ranges Color Start",
      :ranges_color_end => "Ranges Color End",
      :ranges_flour => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Rap Username/)
    rendered.should match(/Rap Password/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/false/)
    rendered.should match(/9.99/)
    rendered.should match(/9.99/)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/Ranges Color Start/)
    rendered.should match(/Ranges Color End/)
    rendered.should match(//)
  end
end
