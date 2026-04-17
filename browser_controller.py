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
