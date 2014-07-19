require 'spec_helper'

feature 'Subscription', js: true do
  STRIPE_CUSTOMER_ID = 'cus_2e3fqARc1uHtCv'
  # STRIPE_SUBSCRIPTION_ID = 'sub_488ZZngNkyRMiR'

  scenario 'user successfully activates a private repo' do
    user = create(:user)
    repo = create(:repo, private: true, in_organization: true)
    repo.users << user
    stub_github_requests(repo)

    stub_customer_create_request(user)
    stub_subscription_create_request

    stub_stripe

    sign_in_as(user)
    find('li.repo .toggle').click

    within '.payment-form' do
      fill_in 'Card Number', with: '4242424242424242'
      fill_in 'Expiration Month', with: 1
      fill_in 'Expiration Year', with: 2018
      fill_in 'CVC', with: 123
      click_button 'Subscribe'
    end

    expect(page).to have_css('.active')
    visit root_path
    expect(page).to have_css('.active')
  end

  def stub_github_requests(repo)
    stub_repo_request(repo.full_github_name)
    stub_add_collaborator_request(repo.full_github_name)
    stub_hook_creation_request(repo.full_github_name, "http://#{ENV['HOST']}/builds")
    stub_user_emails_request(AuthenticationHelper::GITHUB_TOKEN)
  end

  def stub_customer_create_request(user)
    stub_request(
      :post,
      'https://api.stripe.com/v1/customers'
    ).with(
      body: { "card" => "cardtoken", "metadata" => { "user_id"=>"#{user.id}" } },
      headers: { 'Authorization' => "Bearer #{ENV['STRIPE_API_KEY']}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/stripe_customer_create.json'),
      headers: {}
    )
  end

  def stub_subscription_create_request
    stub_request(
      :post,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}/subscriptions"
    ).with(
      body: { 'plan' => 'free' },
      headers: { 'Authorization' => "Bearer #{ENV['STRIPE_API_KEY']}",}
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/stripe_subscription_create.json'),
      headers: {}
    )
  end
end
