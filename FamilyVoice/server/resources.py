
from server import app, socketio, models, db, User, Message, Admin, api
from server.utils import *

from flask_socketio import emit, ConnectionRefusedError
from flask_api import status
from flask import request
from flask_restful import Resource, reqparse
import jwt
import base64

@socketio.on("connect")
def connect():
    """
    Establish a connection with a client and provide them with the token to be included
    in all subsequent HTTP requests
    """
    
    print("connect")
    print("request.cookies=", request.cookies.__dict__)

    devNum = request.args.get("devNum")
    print(request.args)
    
    if not devNum:
        raise ConnectionRefusedError("Device Number was not provided in the URL arguments")
        
    print(devNum)
    print("the members are", User.query.all())
    user = User.query.filter_by(devNum=devNum).first()
    print("the device number is", User.query.filter_by(name="Raf").first().devNum)
    print( User.query.filter_by(name="Raf").first().devNum == devNum)

    
    if not user:
        print("ERROR THROWN")
        raise ConnectionRefusedError("No registered user was found for the provided devince number")
    
    user.room = request.sid 
    db.session.commit()
            
    token = jwt.encode(dict(devNum = devNum), app.config['SECRET_KEY'], algorithm='HS256').decode('utf-8') 
   
    updateTablePayload = getMembersTable(user)
    socketio.emit("wakeUp", dict(token = token, table = updateTablePayload), room=user.room)
    
    if user.incoming.all():
        socketio.emit("messagesExist", room=user.room)
        
@socketio.on("disconnect")
def disconnect():
    """
    Clean up after client disconnects
    """
    
    devNum = request.args.get("devNum")
    print(request.args)
    
    user = User.query.filter_by(devNum=devNum).first()
    
    # Clear the users room to mark them as inactive
    user.room = None
    db.session.commit()
    

        
class MessageAPI(Resource):
    """
    A voice message sent from one user to another
    Supports GETing the message and POSTing a message
    """
    
    def __init__(self):
        super(MessageAPI, self).__init__()

        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument("token", type=str, required=True, help='Token was not provided. error: {error_msg}')
        self.reqparse.add_argument("devNum", type=str, required=True, help='Device number was not provided. error: {error_msg}')
        
    def get(self):
        print("in get message")
        print(request)
        
        args = self.reqparse.parse_args()
        
        try:
            verifyToken(args['token'])
        except jwt.exceptions.InvalidTokenError: 
            return "Not authorized", status.HTTP_403_FORBIDDEN
        
        receiverDevNum = args["devNum"]
        print("devNum is ", receiverDevNum)
        receiver = User.query.filter_by(devNum=receiverDevNum).first()

        if not receiver:
             return f'Could not fetch user with device number {receiverDevNum}', status.HTTP_400_BAD_REQUEST 
            
        message = receiver.incoming.first()
        if message:
            json = dict(sender=message.comingFrom.devNum, data=base64.b64encode(message.data).decode('ascii')) #why encode.decode to send binary data??? becauses PYTHON!!
            db.session.delete(message)
            db.session.commit()
            return json
        else:
            return "No incoming messages", status.HTTP_204_NO_CONTENT
        
    def post(self):
        print("in post message")
        
        with localParseGuard(self.reqparse) as guard:
            guard.add_local_argument('receiver', type=str, required=True, help='receiver device number was not provided. error: {error_msg}', location='json' )
            guard.add_local_argument('data', type=bytes, required=bytes, help='could not obtain data. error: {error_msg}', location='json')
            args = self.reqparse.parse_args()
        
        try:
            verifyToken(args['token'])
        except jwt.exceptions.InvalidTokenError: 
            return "Not authorized", status.HTTP_403_FORBIDDEN

        senderDevNum = args['devNum']
        sender = User.query.filter_by(devNum=senderDevNum).first()
        receiver = User.query.filter_by(devNum=args['receiver']).first()
        data = args["data"]
        print('data is', data)
        if not sender or not receiver  :
            return "Bad sender and/o receiver", status.HTTP_400_BAD_REQUEST

        msg = Message(sender_id=sender.id, receiver_id=receiver.id, data=data)
        db.session.add(msg)
        db.session.commit()
        
        if receiver.incoming.all():
            socketio.emit("messagesExist", room=receiver.room)
        
        return "OK", status.HTTP_200_OK

class TableAPI(Resource):
    """
    The table of users for each sibling along with their order
    supports GETing only
    """
    def __init__(self):
        super(TableAPI, self).__init__()

        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument("token", type=str, required=True, help='Token was not provided. error: {error_msg}')
        self.reqparse.add_argument("devNum", type=str, required=True, help='Device number was not provided. error: {error_msg}')
        
    def get(self):     
        args = self.reqparse.parse_args()

        try:
            verifyToken(args['token'])
        except jwt.exceptions.InvalidTokenError: 
            return "Not authorized", status.HTTP_403_FORBIDDEN
        
        devNum = args["devNum"]
        user = User.query.filter_by(devNum=devNum).first()
        
        if not user:
             return f'Could not fetch user with device number {devNum}', status.HTTP_400_BAD_REQUEST 
            
        return getMembersTable(user)
            
api.add_resource(MessageAPI, '/message', endpoint='message')
api.add_resource(TableAPI, '/table', endpoint='table')

