from server import app
import os

app.config["FV_COMMSERVER_IP"] = os.environ.get('FV_COMMSERVER_IP') or "0.0.0.0"
app.config["FV_COMMSERVER_PORT"] = os.environ.get('FV_COMMSERVER_PORT') or 9999
