require 'spec_helper'

describe "adjustments/index" do
  before(:each) do
    assign(:adjustments, [
      stub_model(Adjustment,
        :weight => "9.99",
        :color => "Color",
        :clarity => "Clarity",
        :cut_vg => 1,
        :cut_g => 2,
        :sym_vg => 3,
        :sym_g => 4,
        :pol_vg => 5,
        :pol_g => 6,
        :flor_faint => 7,
        :flor_medium => 8,
        :flor_strong => 9
      ),
      stub_model(Adjustment,
        :weight => "9.99",
        :color => "Color",
        :clarity => "Clarity",
        :cut_vg => 1,
        :cut_g => 2,
        :sym_vg => 3,
        :sym_g => 4,
        :pol_vg => 5,
        :pol_g => 6,
        :flor_faint => 7,
        :flor_medium => 8,
        :flor_strong => 9
      )
    ])
  end

  it "renders a list of adjustments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "Color".to_s, :count => 2
    assert_select "tr>td", :text => "Clarity".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
    assert_select "tr>td", :text => 7.to_s, :count => 2
    assert_select "tr>td", :text => 8.to_s, :count => 2
    assert_select "tr>td", :text => 9.to_s, :count => 2
  end
end
