import cv2
import threading
import time
from ultralytics import YOLO
from flask import Flask, jsonify, Response

app = Flask(__name__)

# -------------------- GLOBALS --------------------
is_running = False
detector_thread = None
current_frame = None


# -------------------- FALL DETECTOR --------------------
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
        global is_running, current_frame  # ✅ must be indented under the function

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

                    # Check for fall posture (low aspect ratio)
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

            # Status display
            status_text = "Monitoring..." if not fall_detected else "⚠️ Fall Detected!"
            color = (0, 255, 0) if not fall_detected else (0, 0, 255)
            cv2.putText(frame, status_text, (10, 60),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.9, color, 2)

            # Update current frame for streaming
            current_frame = frame

            # Small delay to reduce CPU load
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
            time.sleep(0.03)

        cap.release()
        cv2.destroyAllWindows()
        print("🔴 Detection stopped.")


detector = LocalFallDetector()

# -------------------- API ROUTES --------------------
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


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
