require 'rails_helper'

RSpec.describe 'Visit home', type: :system, js: true do
  it 'shows the homepage' do
    visit '/'
    expect(page).to have_content('Welcome')
  end
end
