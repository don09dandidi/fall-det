import cv2
import threading
import time
from datetime import datetime
from ultralytics import YOLO
from flask import Flask, jsonify, Response, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import requests  # For sending push notifications

# -------------------- FLASK APP CONFIG --------------------
app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///safeguard.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# -------------------- GLOBAL VARIABLES --------------------
is_running = False
detector_thread = None
current_frame = None


# ==========================================================
#                        DATABASE MODELS
# ==========================================================

# -------------------- USER MODEL --------------------
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(120), nullable=False)
    fcm_token = db.Column(db.String(255))  # Firebase Cloud Messaging token

    contacts = db.relationship('Contact', backref='user', lazy=True)
    verifications = db.relationship('Verification', backref='user', lazy=True)
    alerts = db.relationship('Alert', backref='user', lazy=True)

    def to_dict(self):
        return {"id": self.id, "username": self.username}


# -------------------- CONTACT MODEL --------------------
class Contact(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(100))
    phone = db.Column(db.String(20))
    rating = db.Column(db.Integer, default=5)
    active = db.Column(db.Boolean, default=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "role": self.role,
            "phone": self.phone,
            "rating": self.rating,
            "active": self.active,
            "user_id": self.user_id,
        }


# -------------------- VERIFICATION MODEL --------------------
class Verification(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    date = db.Column(db.String(30), nullable=False)
    status = db.Column(db.String(20), default="scheduled")
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "date": self.date,
            "status": self.status,
            "user_id": self.user_id,
        }


# -------------------- ALERT MODEL --------------------
class Alert(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.String(255), nullable=False)
    priority = db.Column(db.String(20), nullable=False)
    status = db.Column(db.String(20), default="Activ")
    category = db.Column(db.String(50), nullable=False)
    time = db.Column(db.String(10), nullable=False)
    date = db.Column(db.String(20), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "priority": self.priority,
            "status": self.status,
            "category": self.category,
            "time": self.time,
            "date": self.date,
            "user_id": self.user_id,
        }


# ==========================================================
#                   PUSH NOTIFICATION SYSTEM
# ==========================================================
def send_push_notification(user_id, title, body):
    """
    Send push notification to user's device using FCM
    You need to set up Firebase Cloud Messaging in your Flutter app
    """
    with app.app_context():
        user = User.query.get(user_id)
        if user and user.fcm_token:
            # FCM Server Key - get this from Firebase Console
            FCM_SERVER_KEY = "YOUR_FCM_SERVER_KEY_HERE"

            headers = {
                'Authorization': f'key={FCM_SERVER_KEY}',
                'Content-Type': 'application/json',
            }

            payload = {
                'to': user.fcm_token,
                'notification': {
                    'title': title,
                    'body': body,
                    'sound': 'default',
                    'priority': 'high',
                },
                'data': {
                    'type': 'fall_detection',
                    'timestamp': datetime.now().isoformat(),
                }
            }

            try:
                response = requests.post(
                    'https://fcm.googleapis.com/fcm/send',
                    headers=headers,
                    json=payload
                )
                print(f"Push notification sent: {response.status_code}")
                return response.status_code == 200
            except Exception as e:
                print(f"Error sending push notification: {e}")
                return False
        return False


# ==========================================================
#                      ALERT ENDPOINTS
# ==========================================================
@app.route('/alerts', methods=['GET'])
def get_alerts():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400

    alerts = Alert.query.filter_by(user_id=user_id).order_by(Alert.created_at.desc()).all()
    return jsonify([a.to_dict() for a in alerts]), 200


@app.route('/alerts', methods=['POST'])
def add_alert():
    data = request.json
    user_id = data.get('user_id')
    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400

    now = datetime.now()
    new_alert = Alert(
        title=data.get('title'),
        description=data.get('description'),
        priority=data.get('priority', 'Mediu'),
        status=data.get('status', 'Activ'),
        category=data.get('category', 'Sistem'),
        time=now.strftime('%H:%M'),
        date=now.strftime('%d %b %Y'),
        user_id=user_id
    )
    db.session.add(new_alert)
    db.session.commit()
    return jsonify({"message": "Alert added successfully", "alert": new_alert.to_dict()}), 201


@app.route('/alerts/<int:id>', methods=['PUT'])
def update_alert(id):
    alert = Alert.query.get_or_404(id)
    data = request.json
    alert.status = data.get('status', alert.status)
    db.session.commit()
    return jsonify({"message": "Alert updated successfully"}), 200


@app.route('/alerts/<int:id>', methods=['DELETE'])
def delete_alert(id):
    alert = Alert.query.get_or_404(id)
    db.session.delete(alert)
    db.session.commit()
    return jsonify({"message": "Alert deleted successfully"}), 200


@app.route('/alerts/stats', methods=['GET'])
def get_alert_stats():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400

    today = datetime.now().strftime('%d %b %Y')

    active_count = Alert.query.filter_by(user_id=user_id, status='Activ').count()
    resolved_today = Alert.query.filter_by(user_id=user_id, status='Rezolvat', date=today).count()
    total_count = Alert.query.filter_by(user_id=user_id).count()

    return jsonify({
        "active": active_count,
        "resolved_today": resolved_today,
        "total": total_count
    }), 200


# ==========================================================
#                      CONTACT ENDPOINTS
# ==========================================================
@app.route('/contacts', methods=['GET'])
def get_contacts():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400

    contacts = Contact.query.filter_by(user_id=user_id).all()
    return jsonify([c.to_dict() for c in contacts]), 200


@app.route('/contacts', methods=['POST'])
def add_contact():
    data = request.json
    user_id = data.get('user_id')
    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400

    new_contact = Contact(
        name=data.get('name'),
        role=data.get('role'),
        phone=data.get('phone'),
        rating=data.get('rating', 5),
        active=data.get('active', True),
        user_id=user_id
    )
    db.session.add(new_contact)
    db.session.commit()
    return jsonify({"message": "Contact added successfully"}), 201


@app.route('/contacts/<int:id>', methods=['PUT'])
def update_contact(id):
    contact = Contact.query.get_or_404(id)
    data = request.json
    contact.name = data.get('name', contact.name)
    contact.role = data.get('role', contact.role)
    contact.phone = data.get('phone', contact.phone)
    contact.rating = data.get('rating', contact.rating)
    contact.active = data.get('active', contact.active)
    db.session.commit()
    return jsonify({"message": "Contact updated successfully"}), 200


@app.route('/contacts/<int:id>', methods=['DELETE'])
def delete_contact(id):
    contact = Contact.query.get_or_404(id)
    db.session.delete(contact)
    db.session.commit()
    return jsonify({"message": "Contact deleted successfully"}), 200


# ==========================================================
#                    VERIFICATION ENDPOINTS
# ==========================================================
@app.route('/verifications', methods=['GET'])
def get_verifications():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400
    verifs = Verification.query.filter_by(user_id=user_id).all()
    return jsonify([v.to_dict() for v in verifs]), 200


@app.route('/verifications', methods=['POST'])
def add_verification():
    data = request.json
    if not data.get('user_id'):
        return jsonify({'error': 'Missing user_id'}), 400

    new_v = Verification(
        title=data.get('title'),
        date=data.get('date'),
        status='scheduled',
        user_id=data.get('user_id')
    )
    db.session.add(new_v)
    db.session.commit()
    return jsonify({'message': 'Verification added successfully'}), 201


@app.route('/verifications/<int:id>', methods=['PUT'])
def update_verification(id):
    v = Verification.query.get_or_404(id)
    data = request.json
    v.status = data.get('status', v.status)
    db.session.commit()
    return jsonify({'message': 'Verification updated successfully'}), 200


@app.route('/verifications/<int:id>', methods=['DELETE'])
def delete_verification(id):
    v = Verification.query.get_or_404(id)
    db.session.delete(v)
    db.session.commit()
    return jsonify({'message': 'Verification deleted successfully'}), 200


# ==========================================================
#                    AUTHENTICATION ENDPOINTS
# ==========================================================
@app.route('/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'error': 'Missing username or password'}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({'error': 'User already exists'}), 400

    hashed_pw = generate_password_hash(password)
    new_user = User(username=username, password=hashed_pw)
    db.session.add(new_user)
    db.session.commit()
    return jsonify({'message': 'User registered successfully'}), 201


@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json(force=True, silent=False)
        print("🔐 /login payload:", data)

        if not data:
            return jsonify({'error': 'Missing JSON body'}), 400

        username = data.get('username')
        password = data.get('password')

        if not username or not password:
            return jsonify({'error': 'Missing username or password'}), 400

        user = User.query.filter_by(username=username).first()

        if user and check_password_hash(user.password, password):
            return jsonify({
                'message': 'Login successful',
                'user': user.to_dict()
            }), 200
        else:
            return jsonify({'error': 'Invalid username or password'}), 401

    except Exception as e:
        import traceback
        print("❌ /login internal error:", e)
        traceback.print_exc()
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/update_fcm_token', methods=['POST'])
def update_fcm_token():
    """Update user's FCM token for push notifications"""
    data = request.json
    user_id = data.get('user_id')
    fcm_token = data.get('fcm_token')

    if not user_id or not fcm_token:
        return jsonify({'error': 'Missing user_id or fcm_token'}), 400

    user = User.query.get(user_id)
    if user:
        user.fcm_token = fcm_token
        db.session.commit()
        return jsonify({'message': 'FCM token updated successfully'}), 200
    else:
        return jsonify({'error': 'User not found'}), 404


# ==========================================================
#                    FALL DETECTOR SYSTEM
# ==========================================================
class LocalFallDetector:
    def __init__(self):
        print("Loading YOLOv8 model...")
        self.model = YOLO('yolov8n.pt')
        print("Model loaded successfully!")

        self.fall_threshold = 0.5
        self.consecutive_fall_frames = 0
        self.fall_threshold_frames = 5
        self.last_alert_time = None
        self.alert_cooldown = 300  # 5 minutes cooldown between alerts

        # Track current fall state for /status
        self.fall_detected = False

    def calculate_aspect_ratio(self, x1, y1, x2, y2):
        width = x2 - x1
        height = y2 - y1
        return height / width if width > 0 else 0

    def create_fall_alert(self, user_id=1):
        """Create a fall detection alert in the database and send push notification"""
        current_time = time.time()

        # Check cooldown
        if self.last_alert_time and (current_time - self.last_alert_time) < self.alert_cooldown:
            return

        self.last_alert_time = current_time
        now = datetime.now()

        with app.app_context():
            new_alert = Alert(
                title="Cădere Detectată!",
                description="Sistem a detectat o posibilă cădere - necesită verificare imediată",
                priority="Ridicat",
                status="Activ",
                category="Detectare Cădere",
                time=now.strftime('%H:%M'),
                date=now.strftime('%d %b %Y'),
                user_id=user_id
            )
            db.session.add(new_alert)
            db.session.commit()
            print(f"🚨 Fall alert created at {now.strftime('%H:%M')}")

            # Push notification
            send_push_notification(
                user_id=user_id,
                title="⚠️ Cădere Detectată!",
                body="Sistemul a detectat o posibilă cădere. Verificați imediat!"
            )

            # Optional: notify emergency contacts
            self.notify_emergency_contacts(user_id)

    def notify_emergency_contacts(self, user_id):
        """Send notifications to all active emergency contacts"""
        with app.app_context():
            contacts = Contact.query.filter_by(user_id=user_id, active=True).all()
            user = User.query.get(user_id)

            for contact in contacts:
                print(f"📞 Emergency contact notified: {contact.name} - {contact.phone}")
                # integrate SMS API here if needed

    def detect_falls(self, video_source=0, user_id=1):
        """Main fall-detection loop running in a background thread"""
        global is_running, current_frame

        # Try to open camera with different backends/indexes
        cap = cv2.VideoCapture(video_source)
        if not cap.isOpened():
            print("MSMF backend failed, trying DirectShow on index 0...")
            cap.release()
            cap = cv2.VideoCapture(video_source, cv2.CAP_DSHOW)

        if not cap.isOpened():
            print("DirectShow index 0 failed, trying DirectShow index 1...")
            cap.release()
            cap = cv2.VideoCapture(1, cv2.CAP_DSHOW)

        if not cap.isOpened():
            print("❌ Error: Could not open any video source (0 or 1).")
            is_running = False
            return

        print("🟢 Fall detection started.")
        alert_created = False

        while is_running:
            ret, frame = cap.read()
            if not ret:
                print("⚠️ Could not read frame from camera.")
                break

            results = self.model(frame, classes=[0], verbose=False)[0]
            self.fall_detected = False  # reset for this frame

            if results.boxes is not None:
                for box in results.boxes:
                    x1, y1, x2, y2 = map(int, box.xyxy[0])
                    confidence = box.conf[0].item()
                    aspect_ratio = self.calculate_aspect_ratio(x1, y1, x2, y2)

                    if aspect_ratio < self.fall_threshold and confidence > 0.5:
                        self.consecutive_fall_frames += 1
                        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 0, 255), 3)
                        cv2.putText(
                            frame,
                            'FALL DETECTED!',
                            (x1, y1 - 10),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.7,
                            (0, 0, 255),
                            2,
                        )
                    else:
                        self.consecutive_fall_frames = max(
                            0, self.consecutive_fall_frames - 1
                        )
                        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                        cv2.putText(
                            frame,
                            f'Ratio: {aspect_ratio:.2f}',
                            (x1, y2 + 20),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.5,
                            (255, 255, 255),
                            1,
                        )

                # Confirm fall if detected for multiple frames
                if self.consecutive_fall_frames >= self.fall_threshold_frames:
                    self.fall_detected = True
                    if not alert_created:
                        self.create_fall_alert(user_id)
                        alert_created = True
                    cv2.putText(
                        frame,
                        '🚨 FALL CONFIRMED!',
                        (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1,
                        (0, 0, 255),
                        3,
                    )
                else:
                    self.fall_detected = False
                    alert_created = False

            # Status overlay
            status_text = "Monitoring..." if self.fall_detected else "No fall"
            color = (0, 0, 255) if self.fall_detected else (0, 255, 0)
            cv2.putText(
                frame,
                status_text,
                (10, 60),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.9,
                color,
                2,
            )

            # Update current frame for streaming
            current_frame = frame

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

            time.sleep(0.03)

        cap.release()
        cv2.destroyAllWindows()
        is_running = False
        self.fall_detected = False
        print("🔴 Detection stopped.")


detector = LocalFallDetector()


# ==========================================================
#                   FALL DETECTION ROUTES
# ==========================================================
@app.route('/video_feed')
def video_feed():
    """Provide live video stream to Flutter via MJPEG"""
    def generate():
        global current_frame, is_running
        while is_running:
            if current_frame is not None:
                _, buffer = cv2.imencode('.jpg', current_frame)
                frame_bytes = buffer.tobytes()
                yield (
                    b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n'
                )
            time.sleep(0.05)

    return Response(
        generate(),
        mimetype='multipart/x-mixed-replace; boundary=frame',
    )


@app.route('/start', methods=['GET'])
def start_detection():
    global is_running, detector_thread
    user_id = int(request.args.get('user_id', 1))

    if is_running:
        return jsonify({"status": "already_running"})

    is_running = True
    detector_thread = threading.Thread(
        target=detector.detect_falls, args=(0, user_id)
    )
    detector_thread.daemon = True
    detector_thread.start()
    return jsonify({"status": "started"})


@app.route('/stop', methods=['GET'])
def stop_detection():
    global is_running
    if not is_running:
        return jsonify({"status": "not_running"})
    is_running = False
    return jsonify({"status": "stopped"})


@app.route('/status', methods=['GET'])
def get_status():
    global is_running
    return jsonify({
        "status": "active" if is_running else "inactive",
        "fall_detected": detector.fall_detected if is_running else False
    })


# ==========================================================
#                            MAIN
# ==========================================================
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)
