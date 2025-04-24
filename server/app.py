from flask import Flask
from flask_cors import CORS
from routes import main_routes

app = Flask(__name__)
CORS(app)

# Register routes
app.register_blueprint(main_routes)

@app.route('/')
def home():
    return "Welcome to the Online Auction Platform API!"

if __name__ == '__main__':
    app.run(debug=True)