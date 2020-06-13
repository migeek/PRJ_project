from app import app
import os
basedir = os.path.abspath(os.path.dirname(__file__))

app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL') or \
    'sqlite:///' + os.path.join(basedir, 'app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_FAMILY_MEMBERS'] = os.environ.get('MAX_FAMILY_MEMBERS') or 5
app.config["MESSAGE_QUEUE_URI"] = os.environ.get('MESSAGE_QUEUE_URI') or "redis://"
