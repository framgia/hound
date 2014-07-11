App.directive 'repo', ['Dialog', (Dialog) ->
  scope: true

  templateUrl: '/templates/repo'

  link: (scope, element, attributes) ->
    repo = scope.repo
    scope.processing = false

    activate = ->
      repo.$activate()
        .then(-> scope.processing = false)
        .catch(-> alert('Your repo failed to activate.'))

    deactivate = ->
      repo.$deactivate()
        .then(-> scope.processing = false)
        .catch(-> alert('Your repo failed to deactivate.'))

    scope.toggle = ->
      scope.processing = true

      if repo.active
        deactivate(repo)
      else
        if repo.private == false
          activate(repo)
        else
          Dialog.open(
            'paymentDialog',
            '/templates/payment_form',
            repo,
            {
              draggable: false
              resizable: false
              autoOpen: false
              modal: true
            }
          ).then(->
            # success
            console.log('closed')
          , ->
            # cancelled
            console.log('cancelled')
          ).finally(->
            scope.processing = false
          )
]
