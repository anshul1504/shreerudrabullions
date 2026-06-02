import json
import logging
import os
import tempfile

import firebase_admin
from firebase_admin import credentials, messaging


_firebase_app = None
logger = logging.getLogger(__name__)


def _get_firebase_app():
    global _firebase_app
    if _firebase_app:
        return _firebase_app

    credentials_json = os.getenv("FIREBASE_CREDENTIALS_JSON", "").strip()
    credentials_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "").strip()

    if credentials_json:
        data = json.loads(credentials_json)
        temp = tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False)
        json.dump(data, temp)
        temp.close()
        credentials_path = temp.name

    if not credentials_path:
        return None

    _firebase_app = firebase_admin.initialize_app(credentials.Certificate(credentials_path))
    return _firebase_app


def send_account_approved_notification(fcm_token):
    if not fcm_token:
        return False
    try:
        app = _get_firebase_app()
        if not app:
            logger.warning("Firebase credentials are not configured; account approval push was skipped.")
            return False

        message = messaging.Message(
            token=fcm_token,
            notification=messaging.Notification(
                title="Account approved",
                body="Your request has been approved. Please login.",
            ),
            data={
                "type": "account_approved",
            },
        )
        messaging.send(message, app=app)
        return True
    except Exception:
        logger.exception("Failed to send account approval push notification.")
        return False
