import jwt
from flask_api import status

def notifyOfMessages(user):
    if not user.room:
        return "Receiver not connected", status.HTTP_202_ACCEPTED
    
    if user.incoming.all():
        socketio.emit("messagesExist", room=user.room)
        
        
def getMembersTable(user):
    membersTable = []
    for order in user.self_orderings:
        assert order.member != user
        membersTable.append((order.member.devNum, order.order))    
    return membersTable


def verifyToken(token):
    
    #remember to remove 
    if token == 'debug':
        return
    
    try:
        print("verifiing token")
        jwt.decode(token, app.config['SECRET_KEY'], algorithm=['HS256'])
    except:
        print("not aouthroized")
        return "Not authorized", status.HTTP_403_FORBIDDEN
    
class localParseGuard:
    def __init__(self, parser):
        self.parser = parser
        self.tempArgNames = []
        
    def add_temporary_argument(self, name, *args, **kwargs):
        self.parser.add_argument(name, *args, **kwargs)
        self.tempArgNames.append(name)
    
    def __enter__(self):
        return self
    
    def __exit__(self, type, value, tb):
        for name in self.tempArgNames:
            self.parser.remove_argument(name)

