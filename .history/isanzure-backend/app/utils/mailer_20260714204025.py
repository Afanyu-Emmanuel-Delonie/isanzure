from flask_mail import Message
from app import mail # Your initialized mail object

def send_otp_email(to_email, otp, name):
    msg = Message(
        subject="Your Verification Code - Isanzure",
        recipients=[to_email],
        html=render_template('emails/otp.html', otp=otp, name=name)
    )
    mail.send(msg)