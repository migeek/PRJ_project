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

from website import app
