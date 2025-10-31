import cv2
import numpy as np
from ultralytics import YOLO
import requests
import time
import threading
from datetime import datetime
import os


class TelegramFallDetector:
    def __init__(self, bot_token, chat_id):
        self.bot_token = bot_token
        self.chat_id = chat_id
        self.fall_threshold = 0.5
        self.alert_cooldown = 30  # seconds between alerts
        self.last_alert_time = 0
        self.consecutive_fall_frames = 0
        self.fall_threshold_frames = 5  # Require 5 consecutive frames of fall detection

        print("Loading YOLOv8 model...")
        self.model = YOLO('yolov8n.pt')
        print("Model loaded successfully!")

        # Test Telegram connection
        if self.test_telegram():
            print("Telegram bot connected successfully!")
        else:
            print("Warning: Telegram connection failed")

    def test_telegram(self):
        """Test if Telegram bot is working"""
        try:
            url = f"https://api.telegram.org/bot{self.bot_token}/getMe"
            response = requests.get(url, timeout=10)
            return response.status_code == 200
        except:
            return False

    def send_telegram_alert(self, frame, aspect_ratio):
        """Send alert with photo and details"""
        current_time = time.time()

        # Cooldown check
        if current_time - self.last_alert_time < self.alert_cooldown:
            return

        try:
            # Save the frame as image
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"fall_alert_{timestamp}.jpg"
            cv2.imwrite(filename, frame)

            # Send photo with caption
            url = f"https://api.telegram.org/bot{self.bot_token}/sendPhoto"
            caption = f"🚨 FALL DETECTED!\n⏰ Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n📐 Aspect Ratio: {aspect_ratio:.2f}\n⚠️ Please check immediately!"

            with open(filename, 'rb') as photo:
                files = {'photo': photo}
                data = {'chat_id': self.chat_id, 'caption': caption}
                response = requests.post(url, files=files, data=data)

            # Send additional text message
            text_url = f"https://api.telegram.org/bot{self.bot_token}/sendMessage"
            text_data = {
                'chat_id': self.chat_id,
                'text': f"🚨 EMERGENCY: Possible fall detected!\nLocation: Unknown\nTime: {datetime.now().strftime('%H:%M:%S')}",
                'parse_mode': 'HTML'
            }
            requests.post(text_url, data=text_data)

            # Clean up the image file
            os.remove(filename)

            self.last_alert_time = current_time
            print(f"Alert sent to Telegram at {datetime.now()}")

        except Exception as e:
            print(f"Error sending Telegram alert: {e}")

    def send_telegram_message(self, message):
        """Send simple text message"""
        try:
            url = f"https://api.telegram.org/bot{self.bot_token}/sendMessage"
            data = {
                'chat_id': self.chat_id,
                'text': message,
                'parse_mode': 'HTML'
            }
            requests.post(url, data=data)
        except Exception as e:
            print(f"Error sending message: {e}")

    def calculate_aspect_ratio(self, x1, y1, x2, y2):
        width = x2 - x1
        height = y2 - y1
        if width > 0:
            return height / width
        return 0

    def detect_falls(self, video_source=0):
        """Main detection function with Telegram alerts"""
        cap = cv2.VideoCapture(video_source)

        if not cap.isOpened():
            print("Error: Could not open video source")
            return

        # Send startup message
        self.send_telegram_message("🟢 Fall detection system STARTED\nMonitoring for falls...")

        print("Fall detection started. Press 'q' to quit.")

        fall_detected = False
        alert_sent = False

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            # Detect people
            results = self.model(frame, classes=[0], verbose=False)[0]

            current_frame_fall = False
            fall_confidence = 0
            fall_aspect_ratio = 0

            if results.boxes is not None:
                for box in results.boxes:
                    x1, y1, x2, y2 = map(int, box.xyxy[0])
                    confidence = box.conf[0].item()

                    aspect_ratio = self.calculate_aspect_ratio(x1, y1, x2, y2)

                    # Fall detection logic
                    if aspect_ratio < self.fall_threshold and confidence > 0.5:
                        current_frame_fall = True
                        fall_confidence = confidence
                        fall_aspect_ratio = aspect_ratio

                        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 0, 255), 3)
                        cv2.putText(frame, 'FALL DETECTED!', (x1, y1 - 10),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)

                        # Count consecutive fall frames
                        self.consecutive_fall_frames += 1
                    else:
                        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                        cv2.putText(frame, f'Person: {confidence:.2f}',
                                    (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)

                    cv2.putText(frame, f'Ratio: {aspect_ratio:.2f}',
                                (x1, y2 + 20), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1)

            # Reset counter if no fall detected in current frame
            if not current_frame_fall:
                self.consecutive_fall_frames = max(0, self.consecutive_fall_frames - 1)

            # Send alert only after consecutive frames to reduce false positives
            if self.consecutive_fall_frames >= self.fall_threshold_frames and not alert_sent:
                fall_detected = True
                alert_sent = True

                # Send alert in a separate thread to not block video processing
                alert_thread = threading.Thread(
                    target=self.send_telegram_alert,
                    args=(frame.copy(), fall_aspect_ratio)
                )
                alert_thread.daemon = True
                alert_thread.start()

                print(f"🚨 Fall confirmed! Sending Telegram alert. Ratio: {fall_aspect_ratio:.2f}")

            # Reset alert if person gets up
            if not current_frame_fall and alert_sent:
                alert_sent = False
                self.send_telegram_message("✅ Person is safe again. Fall alert reset.")
                print("Person is safe - alert system reset")

            # Display status
            status = "FALL DETECTED!" if fall_detected else "Monitoring..."
            color = (0, 0, 255) if fall_detected else (0, 255, 0)
            cv2.putText(frame, status, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)
            cv2.putText(frame, f"Consecutive frames: {self.consecutive_fall_frames}",
                        (10, 70), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

            cv2.imshow('Fall Detection with Telegram Alerts', frame)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

        # Send shutdown message
        self.send_telegram_message("🔴 Fall detection system STOPPED")

        cap.release()
        cv2.destroyAllWindows()
        print("Detection finished.")


def main():
    # Replace these with your actual credentials
    BOT_TOKEN = "YOUR_BOT_TOKEN_HERE"  # From BotFather
    CHAT_ID = "YOUR_CHAT_ID_HERE"  # Your personal chat ID

    # Get credentials if not provided
    if BOT_TOKEN == "YOUR_BOT_TOKEN_HERE":
        BOT_TOKEN = input("Enter your Telegram Bot Token: ").strip()

    if CHAT_ID == "YOUR_CHAT_ID_HERE":
        CHAT_ID = input("Enter your Chat ID: ").strip()

    if not BOT_TOKEN or not CHAT_ID:
        print("Error: Bot token and chat ID are required!")
        return

    detector = TelegramFallDetector(BOT_TOKEN, CHAT_ID)

    print("\n=== Fall Detection with Telegram Alerts ===")
    print("1. Use webcam")
    print("2. Use video file")
    choice = input("Choose option (1 or 2): ").strip()

    if choice == "1":
        print("Starting webcam monitoring...")
        detector.detect_falls(0)
    else:
        video_path = input("Enter video file path: ").strip()
        if video_path and os.path.exists(video_path):
            detector.detect_falls(video_path)
        else:
            print("Invalid path. Using webcam instead.")
            detector.detect_falls(0)


if __name__ == "__main__":
    main()