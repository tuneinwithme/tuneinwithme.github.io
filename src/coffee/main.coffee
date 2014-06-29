app = window.Tuneinwithme

class Main extends app.Base

  init: ->
    app.view.triggerThread 'ready'

app.main = new Main
