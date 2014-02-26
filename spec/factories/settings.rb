# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :setting do
    rap_username "MyString"
    rap_password "MyString"
    price_list_extra_discount 1
    price_list_min_number_of_results_to_display 1
    start_xvfb false
    ranges_size_start "9.99"
    ranges_size_end "9.99"
    ranges_cut ""
    ranges_polish ""
    ranges_sym ""
    ranges_clarity ""
    ranges_color_start "MyString"
    ranges_color_end "MyString"
    ranges_flour ""
  end
end
