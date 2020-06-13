import os, sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
print(__name__)
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
from app import config

db = SQLAlchemy(app)
from app import models
db.create_all()




