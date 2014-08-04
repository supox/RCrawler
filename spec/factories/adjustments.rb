# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :adjustment do
    weight "9.99"
    color "MyString"
    clarity "MyString"
    cut_vg 1
    cut_g 1
    sym_vg 1
    sym_g 1
    pol_vg 1
    pol_g 1
    flor_faint 1
    flor_medium 1
    flor_strong 1
  end
end
