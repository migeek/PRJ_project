from flask import Flask
from flask_login import LoginManager
from flask_bootstrap import Bootstrap
from flask_socketio import SocketIO

from app import app

from website import config

login = LoginManager(app)
bootstrap = Bootstrap(app)
login.login_view = 'login'
socketio = SocketIO(app, logger=True, message_queue=app.config["MESSAGE_QUEUE_URI"])

from website import routes

        
