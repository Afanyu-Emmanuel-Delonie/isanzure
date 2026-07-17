
from app import mail
from flask_mail import Message
from flask import render_template

def send_otp_email(to_email, otp, name):
    msg = Message(
        subject="Your Verification Code - Isanzure",
        recipients=[to_email],
        html=render_template('emails/otp.html', otp=otp, name=name)
    )
    mail.send(msg)