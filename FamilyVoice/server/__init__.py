from flask_restful import  Api
from flask_socketio import SocketIO
from app import app, models, db
from app.models import User, Message, Admin
from server import config, utils
socketio = SocketIO(app, logger=True, message_queue=app.config["MESSAGE_QUEUE_URI"])
api = Api(app)

from server import resources