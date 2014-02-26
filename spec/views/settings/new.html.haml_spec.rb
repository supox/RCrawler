require 'spec_helper'

describe "settings/new" do
  before(:each) do
    assign(:setting, stub_model(Setting,
      :rap_username => "MyString",
      :rap_password => "MyString",
      :price_list_extra_discount => 1,
      :price_list_min_number_of_results_to_display => 1,
      :start_xvfb => false,
      :ranges_size_start => "9.99",
      :ranges_size_end => "9.99",
      :ranges_cut => "",
      :ranges_polish => "",
      :ranges_sym => "",
      :ranges_clarity => "",
      :ranges_color_start => "MyString",
      :ranges_color_end => "MyString",
      :ranges_flour => ""
    ).as_new_record)
  end

  it "renders new setting form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", settings_path, "post" do
      assert_select "input#setting_rap_username[name=?]", "setting[rap_username]"
      assert_select "input#setting_rap_password[name=?]", "setting[rap_password]"
      assert_select "input#setting_price_list_extra_discount[name=?]", "setting[price_list_extra_discount]"
      assert_select "input#setting_price_list_min_number_of_results_to_display[name=?]", "setting[price_list_min_number_of_results_to_display]"
      assert_select "input#setting_start_xvfb[name=?]", "setting[start_xvfb]"
      assert_select "input#setting_ranges_size_start[name=?]", "setting[ranges_size_start]"
      assert_select "input#setting_ranges_size_end[name=?]", "setting[ranges_size_end]"
      assert_select "input#setting_ranges_cut[name=?]", "setting[ranges_cut]"
      assert_select "input#setting_ranges_polish[name=?]", "setting[ranges_polish]"
      assert_select "input#setting_ranges_sym[name=?]", "setting[ranges_sym]"
      assert_select "input#setting_ranges_clarity[name=?]", "setting[ranges_clarity]"
      assert_select "input#setting_ranges_color_start[name=?]", "setting[ranges_color_start]"
      assert_select "input#setting_ranges_color_end[name=?]", "setting[ranges_color_end]"
      assert_select "input#setting_ranges_flour[name=?]", "setting[ranges_flour]"
    end
  end
end
