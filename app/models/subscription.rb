class Subscription < ActiveRecord::Base
  PLANS = {
    personal: 9,
    organization: 24,
    free: 0
  }

  belongs_to :repo
end
