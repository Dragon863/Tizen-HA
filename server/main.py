from flask import Flask, request, jsonify, render_template, redirect
import random
import string

app = Flask(__name__)

codes_tokens = {}
codes_servers = {}

@app.route('/generate_code', methods=['GET'])
def generate_code():
    code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    codes_tokens[code] = 'placeholder'
    codes_servers[code] = 'placeholder'
    return jsonify({'code': code})

@app.route('/', methods=['GET'])
def input_token():
    return render_template('input_token.html')

@app.route('/store_token', methods=['POST'])
def store_token():
    code = request.form['code']
    token = request.form['token']
    server = request.form['url']

    if code in codes_tokens:
        codes_tokens[code] = token
        codes_servers[code] = server
        return redirect('/input_token/success')
    else:
        return redirect('/input_token/error')

@app.route('/input_token/success')
def success():
    return render_template('success.html')

@app.route('/input_token/error')
def error():
    return render_template('error.html')

@app.route('/get_token', methods=['POST'])
def get_token():
    code = request.json['code']
    print(f"Received: {code}")
    print(codes_tokens)
    if code in codes_tokens:
        token = codes_tokens[code]
        server = codes_servers[code]
        if not token == 'placeholder':
            del codes_tokens[code]
            del codes_servers[code]
        return jsonify({'token': token, 'server': server})
    else:
        return jsonify({'error': 'Invalid code'})

if __name__ == '__main__':
 app.run(debug=True, host="0.0.0.0")
