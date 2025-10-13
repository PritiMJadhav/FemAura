from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
import bcrypt

app = Flask(__name__)
CORS(app)

client = MongoClient('mongodb://localhost:27017/')
db = client['mydatabase']
users_collection = db['users']

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')

    if not name or not email or not password:
        return jsonify({'success': False, 'message': 'Name, email, and password are required'}), 400

    if users_collection.find_one({'email': email}):
        return jsonify({'success': False, 'message': 'User already exists'}), 409

    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    users_collection.insert_one({
        'name': name,
        'email': email,
        'password': hashed_password,
        'age': ''
    })

    return jsonify({'success': True, 'message': 'User registered successfully'}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'success': False, 'message': 'Email and password are required'}), 400

    user = users_collection.find_one({'email': email})
    if not user:
        return jsonify({'success': False, 'message': 'User not found'}), 404

    if bcrypt.checkpw(password.encode('utf-8'), user['password']):
        username = user.get('name') or "User"
        age = user.get('age', '')
        return jsonify({
            'success': True,
            'message': 'Login successful',
            'username': username,
            'email': email,
            'age': age
        }), 200
    else:
        return jsonify({'success': False, 'message': 'Invalid password'}), 401

@app.route('/profile/<email>', methods=['GET'])
def get_profile(email):
    user = users_collection.find_one({'email': email}, {'_id': 0, 'password': 0})
    if not user:
        return jsonify({'success': False, 'message': 'User not found'}), 404
    return jsonify({'success': True, 'user': user}), 200

@app.route('/profile/update', methods=['POST'])
def update_profile():
    data = request.json
    email = data.get('email')
    name = data.get('name')
    age = data.get('age')

    if not email:
        return jsonify({'success': False, 'message': 'Email is required'}), 400

    user = users_collection.find_one({'email': email})
    if not user:
        return jsonify({'success': False, 'message': 'User not found'}), 404

    update_data = {}
    if name:
        update_data['name'] = name
    if age:
        update_data['age'] = age

    users_collection.update_one({'email': email}, {'$set': update_data})
    return jsonify({'success': True, 'message': 'Profile updated successfully'}), 200

@app.route('/')
def index():
    return 'Backend is running ✅'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
