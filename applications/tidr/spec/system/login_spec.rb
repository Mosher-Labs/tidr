require 'rails_helper'

RSpec.describe 'Visit home', type: :system do
  it 'shows the homepage' do
    visit '/'
    expect(page).to have_content('Sign In')
  end
end
