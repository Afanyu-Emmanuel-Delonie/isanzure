from flask_mail import Message
from flask import render_template

def send_otp_email(to_email, otp, name):
    from app import mail
    msg = Message(
        subject="Your Verification Code - Isanzure",
        recipients=[to_email],
        html=render_template('emails/otp.html', otp=otp, name=name)
    )
    mail.send(msg)

def send_reset_email(to_email, reset_token, name):
    from app import mail
    msg = Message(
        subject="Reset Your Password - Isanzure",
        recipients=[to_email],
        html=render_template('emails/reset_password.html', reset_token=reset_token, name=name)
    )
    mail.send(msg)