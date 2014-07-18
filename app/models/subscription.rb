class Subscription < ActiveRecord::Base
  PLANS = {
    individual: 9,
    organization: 24,
    free: 0
  }

  has_many :users
  has_many :repos
end
