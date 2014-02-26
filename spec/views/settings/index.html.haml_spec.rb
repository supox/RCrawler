require 'spec_helper'

describe "settings/index" do
  before(:each) do
    assign(:settings, [
      stub_model(Setting,
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
      ),
      stub_model(Setting,
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
      )
    ])
  end

  it "renders a list of settings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Rap Username".to_s, :count => 2
    assert_select "tr>td", :text => "Rap Password".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Ranges Color Start".to_s, :count => 2
    assert_select "tr>td", :text => "Ranges Color End".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
