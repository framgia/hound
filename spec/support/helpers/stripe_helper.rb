module StripeHelper
  STRIPE_ENDPOINT = 'http://stripe.dev'

  def stub_stripe
    WebMock.stub_request(:any, /#{STRIPE_ENDPOINT}/).to_rack(FakeStripe)
    page.execute_script <<-JS
window.onload = function() {
  Stripe.endpoint = '#{STRIPE_ENDPOINT}';
}
    JS
  end
end
