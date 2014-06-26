app = window.Tuneinwithme

class Main extends app.Base

  init: ->
    app.view.trigger 'ready'

app.main = new Main
