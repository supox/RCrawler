require 'spec_helper'

describe "adjustments/show" do
  before(:each) do
    @adjustment = assign(:adjustment, stub_model(Adjustment,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    rendered.should match(/Color/)
    rendered.should match(/Clarity/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
    rendered.should match(/7/)
    rendered.should match(/8/)
    rendered.should match(/9/)
  end
end
