from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, IntegerField, FormField, FieldList, SelectField
from wtforms.validators import ValidationError, DataRequired, Email, EqualTo, NumberRange, ValidationError, Regexp
from app.models import Admin
from app import app

class LoginForm(FlaskForm):
    email = StringField('email', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')

class RegistrationForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    password2 = PasswordField(
        'Repeat Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Register')

    def validate_email(self, email):
        admin = Admin.query.filter_by(email=email.data).first()
        if admin is not None:
            raise ValidationError('Please use a different email address.')
            

class FamilyMemberForm(FlaskForm):
    memberName = StringField('name', validators=[DataRequired()])
    devNum = StringField('devNum', validators=[DataRequired(), Regexp(r'^[\w]+$', message="Only alphanumeric characters are acceptable as Serial Numbers (Hint: Check spaces)")])

class AddMemberForm(FamilyMemberForm):
    add = SubmitField('add')
    
class DelMemberForm(FamilyMemberForm):
    delete = SubmitField('delete')
   
class OrderingForm(FamilyMemberForm):
    order = SelectField('order', choices= [(i,i) for i in range(1,app.config["MAX_FAMILY_MEMBERS"]+1)] , coerce=int, validators=[DataRequired()])
    def __init__(self, *args, **kwargs):
        super(OrderingForm, self).__init__(meta={'csrf':False}, *args, **kwargs)
        
class ConfigMemberForm(FlaskForm):
    memberFields = FieldList(FormField(OrderingForm))
    submit = SubmitField('submit')
    
    def validate_memberFields(self, memberFields):
        orderings = [member.order.data for member in memberFields]
        
        if len(orderings) != len(set(orderings)):
            raise ValidationError("Cannot have members with duplicate orderings")

