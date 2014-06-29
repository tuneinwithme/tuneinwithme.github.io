#!/usr/bin/env python

#!/usr/bin/env python
from SimpleHTTPServer import SimpleHTTPRequestHandler

HOST = 'localhost'
PORT = 63298


class TuneinwithmeHandler(SimpleHTTPRequestHandler):

    # Incorrect but this keeps Chrome from complaining
    extensions_map = SimpleHTTPRequestHandler.extensions_map.copy()
    extensions_map.update({'.coffee': 'text/javascript'})

    # @property
    # def error_message_format(self):
    #     with file('404.html', 'r') as f:
    #         return f.read()

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        SimpleHTTPRequestHandler.end_headers(self)

    def do_GET(self):
        from urlparse import urlparse
        from os import access, R_OK
        urlParams = urlparse(self.path)
        if access('./' + urlParams.path, R_OK):
            SimpleHTTPRequestHandler.do_GET(self)
        else:
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            self.wfile.write(open('views/room.html').read())


def server():
    from BaseHTTPServer import HTTPServer

    try:
        httpd = HTTPServer((HOST, PORT), TuneinwithmeHandler)
        print "Serving tuneinwithme on http://%s:%s ..." % (HOST, PORT)
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    server()
