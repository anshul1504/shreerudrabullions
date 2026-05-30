from django.test import TestCase
from django.contrib.staticfiles.testing import StaticLiveServerTestCase
from django.urls import reverse
from unittest.mock import patch

from .models import ContactEnquiry, Product, ProductCategory, WebsiteSettings


class WebsiteSmokeTests(TestCase):
    def setUp(self):
        WebsiteSettings.objects.get_or_create(id=1, defaults={"site_name": "Test Site"})

    def test_home_page_loads(self):
        response = self.client.get(reverse("website:home"))
        self.assertEqual(response.status_code, 200)

    def test_category_list_page_loads(self):
        response = self.client.get(reverse("website:category_list"))
        self.assertEqual(response.status_code, 200)

    def test_category_list_handles_invalid_numeric_filters(self):
        response = self.client.get(reverse("website:category_list"), {"min_price": "bad"})
        self.assertEqual(response.status_code, 200)

    def test_shop_page_loads(self):
        response = self.client.get(reverse("website:shop"))
        self.assertEqual(response.status_code, 200)

    def test_bullion_rates_page_loads(self):
        response = self.client.get(reverse("website:bullion_rates"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "SILVER PETI TUKDA")
        self.assertContains(response, "GOLD RTGS")

    def test_non_live_page_does_not_fetch_market_rates(self):
        with patch("website.views._fetch_market_bullion_rates") as fetch_rates:
            response = self.client.get(reverse("website:home"))

        self.assertEqual(response.status_code, 200)
        fetch_rates.assert_not_called()

    def test_live_rates_page_fetches_market_rates_once(self):
        market = {
            "gold_10gm": 1000,
            "gold_10gm_bid": 990,
            "gold_10gm_ask": 1010,
            "silver_1kg": 2000,
            "silver_1kg_bid": 1990,
            "silver_1kg_ask": 2010,
            "gold_10gm_high": 1100,
            "gold_10gm_low": 900,
            "silver_1kg_high": 2100,
            "silver_1kg_low": 1900,
            "usd_inr": 83.123,
            "gold_usd": 2300,
            "silver_usd": 30,
            "source": "Test",
            "updated": "Now",
        }
        with patch("website.views._fetch_market_bullion_rates", return_value=market) as fetch_rates:
            response = self.client.get(reverse("website:bullion_rates"))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(fetch_rates.call_count, 1)

    def test_live_rates_hides_inactive_admin_rows(self):
        site = WebsiteSettings.objects.get(id=1)
        site.gold_rtgs_is_active = False
        site.save()

        response = self.client.get(reverse("website:bullion_rates"))

        self.assertEqual(response.status_code, 200)
        self.assertNotContains(response, "GOLD RTGS")
        self.assertContains(response, "SILVER PETI TUKDA")

    def test_inactive_rows_do_not_hide_featured_market_rates(self):
        site = WebsiteSettings.objects.get(id=1)
        site.gold_rtgs_is_active = False
        site.silver_rtgs_is_active = False
        site.save()
        market = {
            "gold_10gm": 155932,
            "gold_10gm_bid": 155851,
            "gold_10gm_ask": 156013,
            "silver_1kg": 267064,
            "silver_1kg_bid": 267000,
            "silver_1kg_ask": 267127,
            "gold_10gm_high": 156013,
            "gold_10gm_low": 156012,
            "silver_1kg_high": 269400,
            "silver_1kg_low": 263900,
            "usd_inr": 94.64,
            "gold_usd": 4538.52,
            "silver_usd": 75.32,
            "source": "Test",
            "updated": "Now",
            "market_open": True,
        }

        with patch("website.views._fetch_market_bullion_rates", return_value=market):
            response = self.client.get(reverse("website:bullion_rates"))

        self.assertEqual(response.status_code, 200)
        self.assertNotContains(response, "SILVER RTGS</div>")
        self.assertContains(response, "Rs 1,55,932")
        self.assertContains(response, "Rs 2,67,064")

    def test_live_rates_market_closed_shows_dash_for_buy_sell(self):
        market = {
            "gold_10gm": 1000,
            "gold_10gm_bid": None,
            "gold_10gm_ask": None,
            "silver_1kg": 2000,
            "silver_1kg_bid": None,
            "silver_1kg_ask": None,
            "gold_10gm_high": 1100,
            "gold_10gm_low": 900,
            "silver_1kg_high": 2100,
            "silver_1kg_low": 1900,
            "usd_inr": 83.123,
            "gold_usd": 2300,
            "silver_usd": 30,
            "source": "Test",
            "updated": "Closed",
            "market_open": False,
        }
        with patch("website.views._fetch_market_bullion_rates", return_value=market):
            response = self.client.get(reverse("website:bullion_rates_data"))

        self.assertEqual(response.status_code, 200)
        payload = response.json()
        self.assertFalse(payload["market_open"])
        self.assertEqual(payload["our_rate_rows"][0]["buy"], "")
        self.assertEqual(payload["our_rate_rows"][0]["sell"], "")

    def test_footer_renders_admin_phone_numbers(self):
        site = WebsiteSettings.objects.get(id=1)
        site.footer_phone_1 = "1111111111"
        site.footer_phone_2 = "2222222222"
        site.footer_phone_3 = "3333333333"
        site.footer_phone_4 = "4444444444"
        site.save()

        response = self.client.get(reverse("website:bullion_rates"))

        self.assertEqual(response.status_code, 200)
        for number in ["1111111111", "2222222222", "3333333333", "4444444444"]:
            self.assertContains(response, number)
            self.assertContains(response, f'tel:{number}')

    def test_privacy_policy_page_loads(self):
        response = self.client.get(reverse("website:privacy_policy"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Privacy Policy")
        self.assertContains(response, "Shree Rudra Bullion")
        self.assertContains(response, "Effective date:") 

    def test_custom_404_page_loads(self):
        response = self.client.get("/missing-page-for-test/")

        self.assertEqual(response.status_code, 404)
        self.assertContains(response, "Page Not Found", status_code=404)
        self.assertContains(response, "View Live Rates", status_code=404)

    def test_category_detail_page_loads(self):
        category = ProductCategory.objects.create(
            title="Gold Coins",
            subtitle="Test",
            banner_image="categories/banners/test.jpg",
            slug="gold-coins",
            is_active=True,
            show_on_home=True,
        )
        response = self.client.get(reverse("website:category", kwargs={"slug": category.slug}))
        self.assertEqual(response.status_code, 200)

    def test_category_detail_handles_invalid_numeric_filters(self):
        category = ProductCategory.objects.create(
            title="Silver Coins",
            subtitle="Test",
            banner_image="categories/banners/test.jpg",
            slug="silver-coins",
            is_active=True,
            show_on_home=True,
        )
        Product.objects.create(
            category=category,
            title="Test Coin",
            slug="test-coin",
            price="1000.00",
            is_active=True,
        )
        response = self.client.get(
            reverse("website:category", kwargs={"slug": category.slug}),
            {"max_price": "not-a-number"},
        )
        self.assertEqual(response.status_code, 200)

    def test_contact_submission_creates_enquiry(self):
        response = self.client.post(
            reverse("website:contact"),
            data={
                "name": "Alice",
                "email": "alice@example.com",
                "phone": "9999999999",
                "enquiry_type": "jewellery",
                "subject": "Need details",
                "message": "Please call me",
            },
        )
        self.assertEqual(response.status_code, 302)
        self.assertEqual(ContactEnquiry.objects.count(), 1)


class FrontendSeleniumTests(StaticLiveServerTestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        from selenium import webdriver
        from selenium.webdriver.chrome.options import Options

        options = Options()
        options.add_argument("--headless=new")
        options.add_argument("--window-size=1366,900")
        options.add_argument("--disable-gpu")
        options.add_argument("--no-sandbox")
        cls.driver = webdriver.Chrome(options=options)
        cls.driver.implicitly_wait(4)

    @classmethod
    def tearDownClass(cls):
        cls.driver.quit()
        super().tearDownClass()

    def setUp(self):
        WebsiteSettings.objects.get_or_create(id=1, defaults={"site_name": "Test Site"})

    def open_path(self, path):
        self.driver.get(f"{self.live_server_url}{path}")

    def test_live_rates_positive_desktop_content_and_icons(self):
        from selenium.webdriver.common.by import By

        self.open_path(reverse("website:bullion_rates"))

        self.assertIn("Live Rates", self.driver.page_source)
        self.assertTrue(self.driver.find_elements(By.CSS_SELECTOR, ".rate-card-icon"))
        self.assertIn("var refreshSeconds = 3;", self.driver.page_source)
        self.assertIn(
            self.driver.find_element(By.CSS_SELECTOR, "[data-refresh-countdown]").text,
            {"1", "2", "3"},
        )
        self.assertIn("GOLD RTGS", self.driver.page_source)
        self.assertIn("SILVER PETI TUKDA", self.driver.page_source)
        self.assertFalse(self.driver.find_elements(By.CSS_SELECTOR, ".unit-box"))
        self.assertTrue(self.driver.find_elements(By.CSS_SELECTOR, ".rate-unit-text"))

    def test_mobile_header_brand_does_not_overlap_logo_or_menu(self):
        from selenium.webdriver.common.by import By

        self.driver.set_window_size(412, 915)
        self.open_path(reverse("website:bullion_rates"))

        logo = self.driver.find_element(By.CSS_SELECTOR, ".site-logo-img")
        brand = self.driver.find_element(By.CSS_SELECTOR, ".site-brand-text")
        menu = self.driver.find_element(By.CSS_SELECTOR, ".mobile-menu-toggler")
        logo_rect = logo.rect
        brand_rect = brand.rect
        menu_rect = menu.rect

        self.assertLessEqual(logo_rect["x"] + logo_rect["width"], brand_rect["x"] + 2)
        self.assertLessEqual(brand_rect["x"] + brand_rect["width"], menu_rect["x"] + 2)
        self.assertIn("SHREE RUDRA", brand.text)
        self.assertTrue(brand.is_displayed())

    def test_contact_positive_submission_reaches_success_state(self):
        from selenium.webdriver.common.by import By

        self.open_path(reverse("website:contact"))
        self.driver.find_element(By.NAME, "name").send_keys("Selenium User")
        self.driver.find_element(By.NAME, "email").send_keys("selenium@example.com")
        self.driver.find_element(By.NAME, "phone").send_keys("9999999999")
        self.driver.find_element(By.NAME, "message").send_keys("Please share rates.")
        self.driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()

        self.assertIn("submitted=1", self.driver.current_url)
        self.assertEqual(ContactEnquiry.objects.count(), 1)

    def test_contact_negative_invalid_email_is_blocked_by_browser(self):
        from selenium.webdriver.common.by import By

        self.open_path(reverse("website:contact"))
        self.driver.find_element(By.NAME, "name").send_keys("Bad Email")
        email = self.driver.find_element(By.NAME, "email")
        email.send_keys("not-an-email")
        self.driver.find_element(By.NAME, "message").send_keys("Invalid email test.")
        self.driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()

        self.assertEqual(ContactEnquiry.objects.count(), 0)
        self.assertNotIn("submitted=1", self.driver.current_url)
        self.assertFalse(self.driver.execute_script("return arguments[0].checkValidity();", email))

    def test_negative_missing_product_returns_404_page(self):
        self.open_path("/product/missing-product/")

        self.assertIn("Not Found", self.driver.title)
