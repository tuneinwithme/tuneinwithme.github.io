#!/usr/bin/env python

from SimpleHTTPServer import SimpleHTTPRequestHandler


class TuneinwithmeHandler(SimpleHTTPRequestHandler):
    @property
    def error_message_format(self):
        with file('404.html', 'r') as f:
            return f.read()


def server():
    from BaseHTTPServer import test, HTTPServer
    try:
        test(TuneinwithmeHandler, HTTPServer)
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    server()
