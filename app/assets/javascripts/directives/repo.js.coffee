App.directive 'repo', ->
  scope: true

  templateUrl: '/templates/repo'

  link: (scope, element, attributes) ->
    repo = scope.repo
    scope.processing = false
    scope.paying = false

    activate = ->
      repo.$activate()
        .then(-> scope.processing = false)
        .catch(-> alert('Your repo failed to activate.'))

    deactivate = ->
      repo.$deactivate()
        .then(-> scope.processing = false)
        .catch(-> alert('Your repo failed to deactivate.'))

    scope.showPaymentForm = ->
      repo.private && scope.paying

    scope.toggle = ->
      if repo.active
        # Need to cancel subscription
        scope.processing = true
        deactivate(repo)
      else
        # There's a chance we won't know the repo info, get it
        if repo.private
          scope.paying = true
        else
          scope.processing = true
          activate(repo)

    scope.subscribe = ->
      event.preventDefault()

      # Stripe.card.createToken(
      #     number: $scope.cardNumber,
      #     exp_month: $scope.expirationMonth,
      #     exp_year: $scope.expirationYear,
      #     cvc: $scope.cvc
      #   , -> (status, response)
      #     subscription = new Subscription(
      #       repo_id: $scope.model.id,
      #       card_token: response.id
      #     )
      #     subscription.$save()
      # )
