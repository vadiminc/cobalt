#!/usr/bin/env python3
"""
Simple HTTP/HTTPS proxy server for tunneling YouTube requests
Run: python3 proxy_server.py
"""

import http.server
import socketserver
import urllib.request
from http.server import SimpleHTTPRequestHandler

class ProxyHTTPRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.proxy_request()
    
    def do_POST(self):
        self.proxy_request()
    
    def do_CONNECT(self):
        # Handle HTTPS tunneling
        self.send_response(200, 'Connection Established')
        self.end_headers()
    
    def proxy_request(self):
        # Forward the request
        url = self.path
        print(f"[PROXY] {self.command} {url}")
        
        try:
            # Get request body if any
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length) if content_length > 0 else None
            
            # Create request
            req = urllib.request.Request(url, data=body, method=self.command)
            
            # Copy headers
            for header, value in self.headers.items():
                if header.lower() not in ['host', 'connection']:
                    req.add_header(header, value)
            
            # Send request
            with urllib.request.urlopen(req, timeout=30) as response:
                self.send_response(response.status)
                
                # Copy response headers
                for header, value in response.headers.items():
                    self.send_header(header, value)
                self.end_headers()
                
                # Copy response body
                self.wfile.write(response.read())
        
        except Exception as e:
            print(f"[ERROR] {e}")
            self.send_error(500, f"Proxy Error: {str(e)}")

PORT = 8888

with socketserver.TCPServer(("", PORT), ProxyHTTPRequestHandler) as httpd:
    print(f"✓ Proxy server running on http://localhost:{PORT}")
    print(f"  Use with: HTTP_PROXY=http://YOUR_TUNNEL_URL")
    print(f"  Press Ctrl+C to stop")
    httpd.serve_forever()

