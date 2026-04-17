import requests
import yaml
import time
import logging
import os

# Setup logging directory
os.makedirs('logs', exist_ok=True)
logging.basicConfig(filename='logs/ml_api.log', level=logging.INFO)

class MultiLoginClient:
    def __init__(self, config_path='config/settings.yaml'):
        with open(config_path, 'r') as file:
            self.config = yaml.safe_load(file)
        self.base_url = self.config['multilogin']['base_url']
        self.api_key = self.config['multilogin']['api_key']
        self.headers = {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        }

    def create_profile(self):
        """Creates a new browser profile."""
        payload = {
            "name": self.config['multilogin']['profile_name'],
            "os": self.config['multilogin']['os_type'],
            "browser": self.config['multilogin']['browser'],
            "resolution": {"width": 1920, "height": 1080}
        }
        response = requests.post(f"{self.base_url}/profiles", json=payload, headers=self.headers)
        if response.status_code == 200:
            profile = response.json()
            logging.info(f"Profile Created: {profile['id']}")
            return profile['id']
        else:
            logging.error(f"Profile Creation Failed: {response.text}")
            return None

    def launch_browser(self, profile_id):
        """Launches a browser session for the profile."""
        url = f"{self.base_url}/profiles/{profile_id}/browser"
        response = requests.post(url, headers=self.headers)
        if response.status_code == 200:
            browser = response.json()
            logging.info(f"Browser Launched: {browser['id']}, URL: {browser['url']}")
            return browser['id'], browser['url']
        else:
            logging.error(f"Browser Launch Failed: {response.text}")
            return None, None

    def get_cookies(self, browser_id):
        """Extracts cookies from the running browser."""
        url = f"{self.base_url}/browser/{browser_id}/cookies"
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            cookies = response.json()
            logging.info(f"Cookies Extracted: {len(cookies)}")
            return cookies
        else:
            logging.error(f"Cookie Extraction Failed: {response.text}")
            return []

    def close_session(self, profile_id):
        """Closes the browser session."""
        url = f"{self.base_url}/profiles/{profile_id}/browser/close"
        requests.post(url, headers=self.headers)
        logging.info(f"Session Closed: {profile_id}")
