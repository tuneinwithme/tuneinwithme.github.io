#!/usr/bin/env python

from BaseHTTPServer import test, HTTPServer
from SimpleHTTPServer import SimpleHTTPRequestHandler

class TuneinwithmeHandler(SimpleHTTPRequestHandler):
    @property
    def error_message_format(self):
      with file('404.html', 'r') as f:
        return f.read()

try: test(TuneinwithmeHandler, HTTPServer)
except KeyboardInterrupt: pass
