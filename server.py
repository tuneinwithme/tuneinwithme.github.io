#!/usr/bin/env python

#!/usr/bin/env python
from SimpleHTTPServer import SimpleHTTPRequestHandler


class TuneinwithmeHandler(SimpleHTTPRequestHandler):
    # @property
    # def error_message_format(self):
    #     with file('404.html', 'r') as f:
    #         return f.read()

    def translate_path(self, path):
        if path.startswith('/assets'):
            return path[1:]
        else:
            return 'views/room.html'


def server():
    from BaseHTTPServer import HTTPServer

    try:
        httpd = HTTPServer(('localhost', 63298), TuneinwithmeHandler)
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    server()
