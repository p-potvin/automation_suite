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
