# work around since python 3 buffers stderr which results on logs not showing in docker
import sys, os

class Unbuffered(object):
   def __init__(self, stream):
       self.stream = stream
   def write(self, data):
       self.stream.write(data)
       self.stream.flush()
   def writelines(self, datas):
       self.stream.writelines(datas)
       self.stream.flush()
   def __getattr__(self, attr):
       return getattr(self.stream, attr)

sys.stderr = Unbuffered(sys.stderr)
sys.stdout = Unbuffered(sys.stdout)


import eventlet
eventlet.monkey_patch()

from server import socketio, app
import argparse

parser = argparse.ArgumentParser()


#parser.add_argument("-hs", "--host", type=str, help="host address", default='localhost')
#parser.add_argument("-p", "--port", type=int, help="port number", default=9999)
#args = parser.parse_args()
#socketio.run(app, host=args.host, port = args.port, debug=True)
