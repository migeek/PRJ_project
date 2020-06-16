from app import app
import os
import jinja2
thisDir = os.path.abspath(os.path.dirname(__file__))

#change the loader to one that looks for templates in the current directory
my_loader = jinja2.ChoiceLoader([jinja2.FileSystemLoader([os.path.join(thisDir, 'templates')])])
app.jinja_loader = my_loader

