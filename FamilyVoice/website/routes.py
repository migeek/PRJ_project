from flask import render_template, flash, redirect, url_for, request, redirect, current_app
from website import app, login, socketio
from app import db, models
from website.forms import LoginForm, RegistrationForm, AddMemberForm, DelMemberForm, ConfigMemberForm
from app.models import Admin, User, Device, Ordering
from flask_login import current_user, login_user, logout_user, login_required
from werkzeug.urls import url_parse
import numpy
    

@login.user_loader
def load_admin(id):
    return Admin.query.get(int(id))



@app.route('/config/<userDev>', methods=['GET', 'POST'])
@login_required
def config(userDev):
    configForm = ConfigMemberForm()

    user = User.query.filter_by(devNum=userDev).first()
    orderings = user.self_orderings.all()

    updateTablePayload = {}
    if configForm.validate_on_submit(): 
        print("in config")
        for memberForm in configForm.memberFields:
            member = User.query.filter_by(devNum = memberForm.devNum.data).first()
            memberOrder = user.self_orderings.filter_by(member_id = member.id).all()
            assert len(memberOrder) == 1
            memberOrder[0].order = int(memberForm.order.data)
            
            #build the update json to give to the user
            updateTablePayload["devNum"] = memberForm.devNum.data
            updateTablePayload["order"] = memberForm.order.data
            
        db.session.commit()
        socketio.emit("updateTable", updateTablePayload, room=user.room)
        
        return redirect(url_for('index'))
    
    while len(configForm.memberFields) < len(orderings):
        configForm.memberFields.append_entry()
        
    for i in range(0, len(orderings)):
        assert len(configForm.memberFields) == len(orderings)
        configForm.memberFields[i].memberName.data = orderings[i].member.name
        configForm.memberFields[i].devNum.data = orderings[i].member.devNum
        configForm.memberFields[i].order.data = orderings[i].order
            
    return render_template('config.html', orderings=configForm, memberName=user.name)
    


@app.route('/')
@app.route('/index', methods=['GET', 'POST'])
@login_required
def index():
    addForm = AddMemberForm()
    delForm = DelMemberForm()
    family = User.query.filter_by(admin_id=current_user.id).all()
    print("index")
    if addForm.add.data and addForm.validate_on_submit():
        print("in add form", addForm.add.label)
        user = User(devNum=addForm.devNum.data, name=addForm.memberName.data, admin_id=current_user.id)
        db.session.add(user)

        orderings = []
        i = 1
        for member in family:
            user.self_orderings.append(Ordering(member_id=member.id, order=i))
            memberOrderings = member.self_orderings.with_entities(Ordering.order).all()
            availableOrderings = numpy.setdiff1d(range(1,current_app.config["MAX_FAMILY_MEMBERS"]), memberOrderings)
            assert len(availableOrderings) != 0
            
            #Why the int converison? Because numpy lists are of type int64 which mysql doesn't like (works fine on sqlite tho).
            member.self_orderings.append(Ordering(member_id=user.id, order=int(availableOrderings[0]))) 
            db.session.add(member)
            i += 1             

        db.session.commit()
        return redirect(url_for('index'))
        
                             
    elif delForm.delete.data and delForm.validate_on_submit():
        print("in del form")
        delete = User.query.filter_by(devNum=delForm.devNum.data).first()
        if delete is not None:
            db.session.delete(delete)
            db.session.commit()
        return redirect(url_for('index'))


    return render_template('index.html', family=family, addForm = addForm, delForm=delForm)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    form = LoginForm()
    if form.validate_on_submit():
        admin = Admin.query.filter_by(email=form.email.data).first()
        if admin is None or not admin.check_password(form.password.data):
            flash('Invalid username or password')
            return redirect(url_for('login'))
        login_user(admin, remember=form.remember_me.data)
        next_page = request.args.get('next')
        if not next_page or url_parse(next_page).netloc != '':
            next_page = url_for('index')
        return redirect(next_page)
    return render_template('login.html', title='Sign In', form=form)
    
    

@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    form = RegistrationForm()
    if form.validate_on_submit():
        admin = Admin(email=form.email.data)
        admin.set_password(form.password.data)
        db.session.add(admin)
        db.session.commit()
        flash('Congratulations, you are now a registered user!')
        return redirect(url_for('login'))
    return render_template('register.html', title='Register', form=form)
    



@app.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('login'))
