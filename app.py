from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/post_message', methods=['POST'])
def post_message():
    data = request.get_json()
    message = data['message']
    signature = data['signature']

    # Process the message and signature here
    print('Message:', message)
    print('Signature:', signature)

    return jsonify({'success': True})

if __name__ == '__main__':
    app.run(debug=True)
