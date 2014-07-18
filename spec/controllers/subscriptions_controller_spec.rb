require 'spec_helper'

describe SubscriptionsController do
  STRIPE_CUSTOMER_ID = 'cus_2e3fqARc1uHtCv'
  STRIPE_SUBSCRIPTION_ID = 'sub_488ZZngNkyRMiR'

  describe '#create' do
    context 'when Stripe customer does not exist' do
      it 'creates a Stripe customer' do
        user = create(:user)
        repo = create(:repo)
        user.repos << repo
        stub_sign_in(user)
        customer_request = stub_customer_create_request(user)
        stub_subscription_create_request

        post :create, card_token: 'cardtoken', repo_id: repo.id

        expect(customer_request).to have_been_requested
      end

      it 'saves the Stripe customer ID' do
        user = create(:user)
        repo = create(:repo)
        user.repos << repo
        stub_sign_in(user)
        stub_customer_create_request(user)
        stub_subscription_create_request

        post :create, card_token: 'cardtoken', repo_id: repo.id

        expect(user.reload.stripe_customer_id).to eq STRIPE_CUSTOMER_ID
      end

      it 'creates a new Stripe subscription' do
        user = create(:user)
        repo = create(:repo)
        user.repos << repo
        stub_sign_in(user)
        stub_customer_create_request(user)
        subscription_request = stub_subscription_create_request

        post :create, card_token: 'cardtoken', repo_id: repo.id

        expect(subscription_request).to have_been_requested
      end

      it 'saves the Stripe subscription ID' do
        user = create(:user)
        repo = create(:repo)
        user.repos << repo
        stub_sign_in(user)
        stub_customer_create_request(user)
        stub_subscription_create_request

        post :create, card_token: 'cardtoken', repo_id: repo.id

        expect(repo.subscription.stripe_subscription_id).to eq STRIPE_SUBSCRIPTION_ID
      end
    end

    context 'when Stripe customer exists' do
      context 'when Stripe subscription does not exist' do
        it 'creates a new Stripe subscription for the customer' do
          user = create(:user, stripe_customer_id: STRIPE_CUSTOMER_ID)
          repo = create(:repo)
          user.repos << repo
          stub_sign_in(user)
          stub_customer_find_request
          subscription_request = stub_subscription_create_request

          post :create, card_token: 'cardtoken', repo_id: repo.id

          expect(subscription_request).to have_been_requested
        end
      end

      context 'when Stripe subscription exists' do
        it 'updates the existing Stripe subscription' do
          user = create(:user, stripe_customer_id: STRIPE_CUSTOMER_ID)
          repo = create(:repo)
          user.repos << repo
          repo.create_subscription(
            user_id: user.id,
            stripe_subscription_id: STRIPE_SUBSCRIPTION_ID
          )
          stub_sign_in(user)
          stub_customer_find_request
          stub_subscription_find_request
          subscription_update_request = stub_subscription_update_request

          post :create, card_token: 'cardtoken', repo_id: repo.id

          expect(subscription_update_request).to have_been_requested
        end
      end
    end
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

  def stub_customer_find_request
    stub_request(
      :get,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}"
    ).with(
      headers: { 'Authorization' => "Bearer #{ENV['STRIPE_API_KEY']}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/stripe_customer_find.json'),
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

  def stub_subscription_find_request
    stub_request(
      :get,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}/subscriptions/#{STRIPE_SUBSCRIPTION_ID}"
    ).with(
      headers: { 'Authorization' => "Bearer #{ENV['STRIPE_API_KEY']}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/stripe_subscription_find.json'),
      headers: {}
    )
  end

  def stub_subscription_update_request
    stub_request(
      :post,
      "https://api.stripe.com/v1/customers/#{STRIPE_CUSTOMER_ID}/subscriptions/#{STRIPE_SUBSCRIPTION_ID}"
    ).with(
      body: { "quantity" => "2" },
      headers: { 'Authorization' => "Bearer #{ENV['STRIPE_API_KEY']}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/stripe_subscription_update.json'),
      headers: {}
    )
  end
end
