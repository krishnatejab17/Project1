from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return """
    <html>
        <head>
            <title>Welcome</title>
        </head>
        <body style="display:flex; justify-content:center; align-items:center; height:100vh; background:#f5f5f5;">
            <h1 style="font-size:60px; font-family:Arial; color:#333;">
                Welcome to T.Kothapalem
            </h1>
        </body>
    </html>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
