import cv2
import threading
import time
from ultralytics import YOLO
from flask import Flask, jsonify, Response, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash

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

    contacts = db.relationship('Contact', backref='user', lazy=True)
    verifications = db.relationship('Verification', backref='user', lazy=True)

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
    status = db.Column(db.String(20), default="scheduled")  # scheduled / completed
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "date": self.date,
            "status": self.status,
            "user_id": self.user_id,
        }


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
    data = request.json
    username = data.get('username')
    password = data.get('password')

    user = User.query.filter_by(username=username).first()
    if user and check_password_hash(user.password, password):
        return jsonify({'message': 'Login successful', 'user': user.to_dict()}), 200
    else:
        return jsonify({'error': 'Invalid username or password'}), 401


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

    def calculate_aspect_ratio(self, x1, y1, x2, y2):
        width = x2 - x1
        height = y2 - y1
        return height / width if width > 0 else 0

    def detect_falls(self, video_source=0):
        global is_running, current_frame
        cap = cv2.VideoCapture(video_source)
        if not cap.isOpened():
            print("Error: Could not open video source")
            return

        print("🟢 Fall detection started.")
        fall_detected = False

        while is_running:
            ret, frame = cap.read()
            if not ret:
                break

            results = self.model(frame, classes=[0], verbose=False)[0]
            current_frame_fall = False

            if results.boxes is not None:
                for box in results.boxes:
                    x1, y1, x2, y2 = map(int, box.xyxy[0])
                    confidence = box.conf[0].item()
                    aspect_ratio = self.calculate_aspect_ratio(x1, y1, x2, y2)

                    # Check for fall posture
                    if aspect_ratio < self.fall_threshold and confidence > 0.5:
                        current_frame_fall = True
                        self.consecutive_fall_frames += 1
                        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 0, 255), 3)
                        cv2.putText(frame, 'FALL DETECTED!', (x1, y1 - 10),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
                    else:
                        self.consecutive_fall_frames = max(0, self.consecutive_fall_frames - 1)
                        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                        cv2.putText(frame, f'Ratio: {aspect_ratio:.2f}', (x1, y2 + 20),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

                # Confirm fall if detected for multiple frames
                if self.consecutive_fall_frames >= self.fall_threshold_frames:
                    fall_detected = True
                    cv2.putText(frame, '🚨 FALL CONFIRMED!', (10, 30),
                                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 3)
                else:
                    fall_detected = False

            # Display status
            status_text = "Monitoring..." if not fall_detected else "⚠️ Fall Detected!"
            color = (0, 255, 0) if not fall_detected else (0, 0, 255)
            cv2.putText(frame, status_text, (10, 60),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.9, color, 2)

            # Update current frame for streaming
            current_frame = frame

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
            time.sleep(0.03)

        cap.release()
        cv2.destroyAllWindows()
        print("🔴 Detection stopped.")


detector = LocalFallDetector()


# ==========================================================
#                   FALL DETECTION ROUTES
# ==========================================================
@app.route('/video_feed')
def video_feed():
    """Provide live video stream to Flutter via MJPEG"""
    def generate():
        global current_frame
        while is_running:
            if current_frame is not None:
                _, buffer = cv2.imencode('.jpg', current_frame)
                frame_bytes = buffer.tobytes()
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
            time.sleep(0.05)
    return Response(generate(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')


@app.route('/start', methods=['GET'])
def start_detection():
    global is_running, detector_thread
    if is_running:
        return jsonify({"status": "already_running"})
    is_running = True
    detector_thread = threading.Thread(target=detector.detect_falls, args=(0,))
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
    return jsonify({"status": "active" if is_running else "inactive"})


# ==========================================================
#                            MAIN
# ==========================================================
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)
