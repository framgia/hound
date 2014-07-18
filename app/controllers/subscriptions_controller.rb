class SubscriptionsController < ApplicationController
  def create
    subscription = find_subscription

    if subscription
      subscription.quantity = subscription.quantity + 1
      subscription.save
    else
      create_subscription
    end

    head 201
  end

  private

  def find_subscription
    subscription = repo.subscription

    if subscription && subscription.stripe_subscription_id
      customer.subscriptions.retrieve(subscription.stripe_subscription_id)
    end
  end

  def create_subscription
    subscription = customer.subscriptions.create(plan: repo.plan)

    repo.create_subscription(
      user_id: current_user.id,
      stripe_subscription_id: subscription.id
    )

    subscription
  end

  def customer
    find_customer || create_customer
  end

  def find_customer
    customer_id = current_user.stripe_customer_id

    if customer_id.present?
      Stripe::Customer.retrieve(customer_id)
    end
  end

  def create_customer
    customer = Stripe::Customer.create(
      email: current_user.email_address,
      metadata: {
        user_id: current_user.id
      },
      card: params[:card_token]
    )

    current_user.update_attribute(:stripe_customer_id, customer.id)

    customer
  end

  def repo
    current_user.repos.find(params[:repo_id])
  end
end
