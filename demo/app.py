import http.server
import os
import sys

class Server(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        response = "Hello from GKE!\n"
        for var in ["NAMESPACE", "POD_NAME", "NODE_NAME"]:
            response += f"{var}: " + os.environ.get(f"KUBERNETES_{var}", "N/A") + "\n"
        self.wfile.write(response.encode('utf-8'))

if __name__ == '__main__':
    port = 8080
    http.server.HTTPServer(('0.0.0.0', port), Server).serve_forever()