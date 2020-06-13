import requests
import socketio
from sys import argv

tok = 0

socket = socketio.Client()
url = "http://localhost:9999"

@socket.event
def message(t):
    print(t)
    
    
socket.connect(url) 


    
    
