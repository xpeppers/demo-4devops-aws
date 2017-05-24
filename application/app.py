from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello mate! I am tiny service on <br> Hostname:"'+socket.gethostname()+'"<br> Version:"'+ os.getenv("TAG_VERSION", 'Not defined')+'"'

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv('PORT', 80)), debug=True)
