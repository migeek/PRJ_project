import jwt
from flask_api import status

        
        
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
    
    print("verifiing token")
    jwt.decode(token, app.config['SECRET_KEY'], algorithm=['HS256'])

    
class localParseGuard:
    def __init__(self, parser):
        self.parser = parser
        self.tempArgNames = []
        
    def add_local_argument(self, name, *args, **kwargs):
        self.parser.add_argument(name, *args, **kwargs)
        self.tempArgNames.append(name)
    
    def __enter__(self):
        return self
    
    def __exit__(self, type, value, tb):
        for name in self.tempArgNames:
            self.parser.remove_argument(name)

