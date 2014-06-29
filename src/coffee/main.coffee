app = window.Tuneinwithme

class Main extends app.Base

  init: ->
    app.FIREBASE_API = 'https://tuneinwithme.firebaseio.com/v1'
    app.view.triggerThread 'ready'

app.main = new Main
