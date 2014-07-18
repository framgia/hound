require 'spec_helper'

feature 'Subscription', js: true do
  scenario 'user activates a private repo' do
    user = create(:user)
    repo = create(:repo, private: true, in_organization: true)
    repo.users << user
    stub_repo_request(repo.full_github_name)
    stub_user_emails_request(AuthenticationHelper::GITHUB_TOKEN)
    stub_stripe

    sign_in_as(user)
    find('li.repo .toggle').click

    expect(page).to have_content "$#{Subscription::PLANS.fetch(:organization)}"
  end
end
