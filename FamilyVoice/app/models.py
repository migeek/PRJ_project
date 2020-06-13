from app import db
from werkzeug.security import generate_password_hash, check_password_hash 
from flask_login import UserMixin


class Admin(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(64), index=True, unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    members = db.relationship('User', backref='admin', lazy='dynamic')
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)    
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def __repr__(self):
        return '<Admin {}>'.format(self.email) 

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), index=True, nullable=False)
    devNum = db.Column(db.String(64), index=True, nullable=False, unique=True) # should be when devices have been manfucatured db.Column(db.String(120), db.ForeignKey('device.serialNum'), nullable=False)
    admin_id = db.Column(db.Integer, db.ForeignKey('admin.id'), nullable=False)
    room = db.Column(db.String(128), unique=True)
    
    self_orderings = db.relationship("Ordering", cascade="all, delete-orphan", backref="host", lazy="dynamic", foreign_keys="Ordering.host_id")
    other_orderings = db.relationship("Ordering", cascade="all, delete-orphan", backref="member", lazy="dynamic", foreign_keys="Ordering.member_id")
    
    outgoing = db.relationship("Message", cascade="all, delete-orphan", backref="comingFrom", lazy="dynamic", foreign_keys="Message.sender_id")
    incoming = db.relationship("Message", cascade="all, delete-orphan", backref="goingTo", lazy="dynamic", foreign_keys="Message.receiver_id")

    def __repr__(self):
        return '<User {}>'.format(self.name) 
    

class Ordering(db.Model):

    host_id = db.Column(db.Integer, db.ForeignKey('user.id'), primary_key=True)
    member_id = db.Column(db.Integer, db.ForeignKey('user.id'), primary_key=True)
    order = db.Column(db.Integer, nullable=False)

    __table_args__ = (db.CheckConstraint(host_id != member_id),)

class Message(db.Model):
    """ 
    This model is to store the pending voice messages is only
    used on the communication server's side
    """
    id = db.Column(db.Integer, index=True, primary_key=True)
    receiver_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    sender_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    data = db.Column(db.LargeBinary)
    
class Device(db.Model):
    serialNum = db.Column(db.String(120), index=True, primary_key=True)
    def __repr__(self):
        return '<Device {}>'.format(self.serialNum) 
        

    
 
