import eventlet
eventlet.monkey_patch()

from flask_socketio import SocketIO
from app import app
from app.models import User, Message, Admin
from server import config
from flask import request
from flask_socketio import emit, send, ConnectionRefusedError
from sys import argv


socketio = SocketIO(app, logger=True, message_queue='redis://')
@socketio.on("message")
def test(msg):
    socketio.emit('message', msg['body'] + " from room " + request.sid, room=msg.get('room'))

socketio.run(app, port = int(argv[1]), debug=True)
