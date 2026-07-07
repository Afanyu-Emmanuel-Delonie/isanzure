import io
import hmac
import hashlib
import json
import base64
import qrcode
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer, Image, Paragraph
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER
from config import settings


# ── Token ─────────────────────────────────────────────────────────────────────

def generate_ticket_token(booking_id: str, user_id: str) -> str:
    """HMAC-SHA256 signed token encoding booking_id + user_id."""
    payload = json.dumps({"booking_id": booking_id, "user_id": user_id}, separators=(',', ':'))
    encoded = base64.urlsafe_b64encode(payload.encode()).decode()
    sig = hmac.new(settings.JWT_SECRET_KEY.encode(), encoded.encode(), hashlib.sha256).hexdigest()
    return f"{encoded}.{sig}"


def verify_ticket_token(token: str) -> dict | None:
    """Returns decoded payload dict if signature is valid, else None."""
    try:
        encoded, sig = token.rsplit('.', 1)
        expected = hmac.new(settings.JWT_SECRET_KEY.encode(), encoded.encode(), hashlib.sha256).hexdigest()
        if not hmac.compare_digest(sig, expected):
            return None
        return json.loads(base64.urlsafe_b64decode(encoded.encode()).decode())
    except Exception:
        return None


# ── QR Code ───────────────────────────────────────────────────────────────────

def _build_qr_image(token: str) -> io.BytesIO:
    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=6,
        border=2,
    )
    qr.add_data(token)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)
    return buf


# ── PDF ───────────────────────────────────────────────────────────────────────

def generate_ticket_pdf(booking: dict, passenger_name: str, passenger_email: str) -> io.BytesIO:
    """
    booking keys: id, seat_number, departure_time, origin, destination,
                  price, plate_number, agency_name, user_id
    Returns a BytesIO containing the PDF.
    """
    token = generate_ticket_token(str(booking["id"]), str(booking["user_id"]))
    qr_buf = _build_qr_image(token)

    buf = io.BytesIO()
    doc = SimpleDocTemplate(
        buf,
        pagesize=A4,
        leftMargin=20 * mm,
        rightMargin=20 * mm,
        topMargin=20 * mm,
        bottomMargin=20 * mm,
    )

    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        "title", parent=styles["Heading1"],
        fontSize=22, textColor=colors.HexColor("#1a1a2e"),
        alignment=TA_CENTER, spaceAfter=4
    )
    sub_style = ParagraphStyle(
        "sub", parent=styles["Normal"],
        fontSize=10, textColor=colors.HexColor("#555555"),
        alignment=TA_CENTER, spaceAfter=12
    )
    label_style = ParagraphStyle(
        "label", parent=styles["Normal"],
        fontSize=9, textColor=colors.HexColor("#888888")
    )
    value_style = ParagraphStyle(
        "value", parent=styles["Normal"],
        fontSize=12, textColor=colors.HexColor("#1a1a2e")
    )

    elements = []

    # Header
    elements.append(Paragraph("ISANZURE", title_style))
    elements.append(Paragraph("Bus Ticket", sub_style))
    elements.append(Spacer(1, 4 * mm))

    # Route banner
    route_data = [[
        Paragraph(f"<b>{booking['origin']}</b>", ParagraphStyle("r", fontSize=16, alignment=TA_CENTER, textColor=colors.white)),
        Paragraph("→", ParagraphStyle("arr", fontSize=18, alignment=TA_CENTER, textColor=colors.white)),
        Paragraph(f"<b>{booking['destination']}</b>", ParagraphStyle("r", fontSize=16, alignment=TA_CENTER, textColor=colors.white)),
    ]]
    route_table = Table(route_data, colWidths=[70 * mm, 20 * mm, 70 * mm])
    route_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#1a1a2e")),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
        ("ROUNDEDCORNERS", [4, 4, 4, 4]),
    ]))
    elements.append(route_table)
    elements.append(Spacer(1, 6 * mm))

    # Details + QR side by side
    def _cell(label, value):
        return [Paragraph(label, label_style), Paragraph(str(value), value_style)]

    details = [
        _cell("Passenger", passenger_name),
        _cell("Email", passenger_email),
        _cell("Departure", booking["departure_time"]),
        _cell("Seat", f"#{booking['seat_number']}"),
        _cell("Bus Plate", booking["plate_number"]),
        _cell("Agency", booking["agency_name"]),
        _cell("Price", f"RWF {booking['price']:,.0f}"),
        _cell("Booking ID", str(booking["id"])),
    ]

    qr_img = Image(qr_buf, width=45 * mm, height=45 * mm)

    info_table = Table(details, colWidths=[35 * mm, 85 * mm])
    info_table.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("TOPPADDING", (0, 0), (-1, -1), 3),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
        ("LINEBELOW", (0, 0), (-1, -2), 0.3, colors.HexColor("#eeeeee")),
    ]))

    side_table = Table([[info_table, qr_img]], colWidths=[125 * mm, 50 * mm])
    side_table.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("ALIGN", (1, 0), (1, 0), "CENTER"),
        ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#dddddd")),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("RIGHTPADDING", (0, 0), (-1, -1), 8),
    ]))
    elements.append(side_table)
    elements.append(Spacer(1, 6 * mm))

    # Footer
    elements.append(Paragraph(
        "Scan the QR code at boarding for verification. This ticket is non-transferable.",
        ParagraphStyle("footer", parent=styles["Normal"], fontSize=8,
                       textColor=colors.HexColor("#aaaaaa"), alignment=TA_CENTER)
    ))

    doc.build(elements)
    buf.seek(0)
    return buf
