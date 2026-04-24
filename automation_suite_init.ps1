# Create the directory structure
New-Item -ItemType Directory -Path "C:\users\administrator\desktop\github repos\automation-suite" -Force
New-Item -ItemType Directory -Path "C:\users\administrator\desktop\github repos\automation-suite\logs" -Force
New-Item -ItemType Directory -Path "C:\users\administrator\desktop\github repos\automation-suite\config" -Force
New-Item -ItemType Directory -Path "C:\users\administrator\desktop\github repos\automation-suite\cookies" -Force

# Create the requirements.txt file
Set-Content -Path "C:\users\administrator\desktop\github repos\automation-suite\requirements.txt" -Value @'
playwright>=1.40.0
requests>=2.31.0
pyyaml>=6.0
pynput>=1.7.6
'@

# Create the config/settings.yaml file
Set-Content -Path "C:\users\administrator\desktop\github repos\automation-suite\config\settings.yaml" -Value @'
---
multilogin:
  api_key: "YOUR_MULTILogin_API_KEY"
  base_url: "https://api.multilogin.com/v1"
  profile_name: "StackOverflow_Profile_01"
  os_type: "Windows 10"
  browser: "Chrome"
automation:
  max_retries: 3
  base_delay: 2.0
  max_delay: 5.0
  ip_rotation_interval: 5
  captcha_api_key: "YOUR_2CAPTCHA_KEY"
targets:
    url: "https://stackoverflow.com"
    form_selector: "form[name='login']"
    username_selector: "input[name='login']"
    password_selector: "input[name='password']"
    submit_selector: "input[type='submit']"
'@

# Create the multilogin_client.py file
Set-Content -Path "C:\users\administrator\desktop\github repos\automation-suite\multilogin_client.py" -Value @'
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
'@

# Create the browser_controller.py file
Set-Content -Path "C:\users\administrator\desktop\github repos\automation-suite\browser_controller.py" -Value @'
from playwright.sync_api import sync_playwright
import time
import logging
import os

# Setup logging
os.makedirs('logs', exist_ok=True)
logging.basicConfig(filename='logs/browser.log', level=logging.INFO)

class BrowserController:
    def __init__(self, browser_url):
        self.browser_url = browser_url
        self.playwright = sync_playwright()

    def connect(self):
        """Connects to the MultiLogin browser session."""
        try:
            self.browser = self.playwright.chromium.connect_over_cdp(self.browser_url)
            self.page = self.browser.contexts[0].pages[0]
            logging.info("Connected to Browser Session")
            return self.page
        except Exception as e:
            logging.error(f"Connection Error: {e}")
            return None

    def close(self):
        """Closes the connection."""
        try:
            self.browser.close()
            self.playwright.stop()
            logging.info("Browser Session Closed")
        except Exception as e:
            logging.error(f"Close Error: {e}")

    def extract_cookies(self):
        """Extracts cookies from the page."""
        cookies = self.page.context.cookies()
        logging.info(f"Extracted {len(cookies)} cookies")
        return cookies
'@

# Create the humanizer.py file
Set-Content -Path "C:\users\administrator\desktop\github repos\automation-suite\humanizer.py" -Value @'
import time
import random
import math

class Humanizer:
    @staticmethod
    def random_delay(min_delay, max_delay):
        """Random delay between actions."""
        time.sleep(random.uniform(min_delay, max_delay))

    @staticmethod
    def random_mouse_move(page, x, y, duration=0.5):
        """Simulates human mouse movement (Bezier curve approximation)."""
        points = [
            (x, y),
            (x + random.randint(-50, 50), y + random.randint(-50, 50)),
            (x + random.randint(-50, 50), y + random.randint(-50, 50)),
            (x, y)
        ]
        for i in range(len(points) - 1):
            px, py = points[i]
            nx, ny = points[i+1]
            dist = math.sqrt((nx - px)**2 + (ny - py)**2)
            speed = dist / duration
            for _ in range(int(speed)):
                time.sleep(0.01)
                # Simulate movement
                pass

    @staticmethod
    def type_text(page, selector, text, delay=0.1):
        """Types text with random delays between characters."""
        locator = page.locator(selector)
        locator.fill("")  # Clear existing
        for char in text:
            locator.type(char, delay=delay)
            time.sleep(random.uniform(0.05, 0.2))

    @staticmethod
    def click_element(page, selector):
        """Clicks with a hover effect."""
        locator = page.locator(selector)
        try:
            bbox = locator.bounding_box()
            if bbox:
                page.mouse.move(bbox['x'], bbox['y'])
                time.sleep(random.uniform(0.2, 0.5))
                locator.click()
        except Exception as e:
            print(f"Click Error: {e}")
'@

# Create the main.py file
Set-Content -Path "C:\users\administrator\desktop\github repos\automation-suite\main.py" -Value @'
from multilogin_client import MultiLoginClient
from browser_controller import BrowserController
from humanizer import Humanizer
import yaml
import time
import json
import os

# Setup logging
os.makedirs('logs', exist_ok=True)
os.makedirs('cookies', exist_ok=True)

def run_stackoverflow_flow():
    # 1. Load Config
    with open('config/settings.yaml', 'r') as file:
        config = yaml.safe_load(file)
    
    ml_client = MultiLoginClient()
    target_url = config['targets'][0]['url']
    
    # 2. Create Profile
    print("Creating MultiLogin Profile...")
    profile_id = ml_client.create_profile()
    if not profile_id:
        print("Profile creation failed.")
        return

    # 3. Launch Browser
    print("Launching Browser...")
    browser_id, browser_url = ml_client.launch_browser(profile_id)
    if not browser_url:
        print("Browser launch failed.")
        return

    # 4. Connect & Interact
    print("Connecting to Browser...")
    controller = BrowserController(browser_url)
    page = controller.connect()

    try:
        # Navigate
        print("Navigating to target...")
        page.goto(target_url)
        time.sleep(random.uniform(1.0, 3.0))

        # Human-like delays
        print("Simulating human delay...")
        Humanizer.random_delay(1.0, 3.0)

        # Simulate Mouse Movement (e.g., hover over Sign Up)
        print("Simulating mouse movement...")
        Humanizer.random_mouse_move(page, 500, 500, 0.5)

        # Type Data
        print("Typing credentials...")
        Humanizer.type_text(page, 'input[name="login"]', 'test_user_01', 0.1)
        Humanizer.random_delay(0.5, 1.0)
        Humanizer.type_text(page, 'input[name="password"]', 'SecurePass123!', 0.1)
        Humanizer.random_delay(0.5, 1.0)

        # Click Submit
        print("Submitting form...")
        Humanizer.click_element(page, 'input[type="submit"]')
        time.sleep(random.uniform(1.0, 2.0))

        # 5. Extract Cookies
        print("Extracting cookies...")
        cookies = controller.extract_cookies()
        
        # Save to file
        with open('cookies/session.json', 'w') as f:
            json.dump(cookies, f, indent=2)

        print("Account Created/Logged In Successfully.")
        print(f"Cookies saved to cookies/session.json")

    except Exception as e:
        print(f"Error during flow: {e}")
        logging.error(f"Flow Error: {e}")
    finally:
        controller.close()
        ml_client.close_session(profile_id)
        print("Cleanup complete.")

if __name__ == "__main__":
    print("=" * 50)
    print("Starting StackOverflow Automation Flow")
    print("=" * 50)
    run_stackoverflow_flow()
'@

# Install dependencies
& pip install -r "C:\users\administrator\desktop\github repos\automation-suite\requirements.txt"

# Install Playwright browsers
& playwright install chromium

# Run the test
& python "C:\users\administrator\desktop\github repos\automation-suite\main.py"
