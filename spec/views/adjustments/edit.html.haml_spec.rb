require 'spec_helper'

describe "adjustments/edit" do
  before(:each) do
    @adjustment = assign(:adjustment, stub_model(Adjustment,
      :weight => "9.99",
      :color => "MyString",
      :clarity => "MyString",
      :cut_vg => 1,
      :cut_g => 1,
      :sym_vg => 1,
      :sym_g => 1,
      :pol_vg => 1,
      :pol_g => 1,
      :flor_faint => 1,
      :flor_medium => 1,
      :flor_strong => 1
    ))
  end

  it "renders the edit adjustment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", adjustment_path(@adjustment), "post" do
      assert_select "input#adjustment_weight[name=?]", "adjustment[weight]"
      assert_select "input#adjustment_color[name=?]", "adjustment[color]"
      assert_select "input#adjustment_clarity[name=?]", "adjustment[clarity]"
      assert_select "input#adjustment_cut_vg[name=?]", "adjustment[cut_vg]"
      assert_select "input#adjustment_cut_g[name=?]", "adjustment[cut_g]"
      assert_select "input#adjustment_sym_vg[name=?]", "adjustment[sym_vg]"
      assert_select "input#adjustment_sym_g[name=?]", "adjustment[sym_g]"
      assert_select "input#adjustment_pol_vg[name=?]", "adjustment[pol_vg]"
      assert_select "input#adjustment_pol_g[name=?]", "adjustment[pol_g]"
      assert_select "input#adjustment_flor_faint[name=?]", "adjustment[flor_faint]"
      assert_select "input#adjustment_flor_medium[name=?]", "adjustment[flor_medium]"
      assert_select "input#adjustment_flor_strong[name=?]", "adjustment[flor_strong]"
    end
  end
end
