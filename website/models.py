from django.db import models

class WebsiteSettings(models.Model):
    RATE_SOURCE_CHOICES = (
        ("api", "API Live Rates"),
        ("manual", "Manual Admin Rates"),
        ("hybrid", "Hybrid (API + Admin Tuning)"),
    )
    RATE_FORMULA_CHOICES = (
        ("+", "Addition (+)"),
        ("-", "Subtraction (-)"),
        ("*", "Multiply (*)"),
        ("/", "Divide (/)"),
        ("%", "Percentage Markup (%)"),
    )
    RATE_ADJUSTMENT_CHOICES = (
        ("+", "Addition (+)"),
        ("-", "Subtraction (-)"),
    )
    site_name = models.CharField(max_length=200, default="Shree Rudra Bullion")
    tagline = models.CharField(max_length=255, blank=True)

    logo = models.ImageField(upload_to="site/", blank=True, null=True)
    footer_logo = models.ImageField(upload_to="site/", blank=True, null=True)

    phone = models.CharField(max_length=20, blank=True)
    footer_phone_1 = models.CharField("Footer phone 1", max_length=20, blank=True)
    footer_phone_2 = models.CharField("Footer phone 2", max_length=20, blank=True)
    footer_phone_3 = models.CharField("Footer phone 3", max_length=20, blank=True)
    footer_phone_4 = models.CharField("Footer phone 4", max_length=20, blank=True)
    email = models.EmailField(blank=True)

    address = models.TextField(blank=True)

    # 🔥 NEW: WhatsApp QR Image
    whatsapp_qr = models.ImageField(
        upload_to="site/qr/",
        blank=True,
        null=True,
        help_text="Upload WhatsApp QR Code (PNG/JPG)"
    )

    # 🔥 OFFICE TIMINGS (NEW)
    weekday_label = models.CharField(
        max_length=100,
        default="Monday - Saturday"
    )
    weekday_time = models.CharField(
        max_length=100,
        default="11am - 7pm ET"
    )

    sunday_label = models.CharField(
        max_length=100,
        default="Sunday"
    )
    sunday_time = models.CharField(
        max_length=100,
        default="11am - 6pm ET"
    )

    footer_text = models.TextField(blank=True)

    facebook = models.URLField(blank=True)
    instagram = models.URLField(blank=True)
    twitter = models.URLField(blank=True)
    youtube = models.URLField(blank=True)

    meta_keywords = models.CharField(max_length=255, blank=True)
    meta_description = models.CharField(max_length=255, blank=True)
    gold_rate = models.CharField(max_length=100, blank=True, default="")
    silver_rate = models.CharField(max_length=100, blank=True, default="")
    gold_buy_rate = models.CharField(max_length=100, blank=True, default="")
    gold_sell_rate = models.CharField(max_length=100, blank=True, default="")
    silver_buy_rate = models.CharField(max_length=100, blank=True, default="")
    silver_sell_rate = models.CharField(max_length=100, blank=True, default="")
    our_gold_rate = models.CharField(max_length=100, blank=True, default="")
    our_silver_rate = models.CharField(max_length=100, blank=True, default="")
    our_gold_buy_rate = models.CharField(max_length=100, blank=True, default="")
    our_gold_sell_rate = models.CharField(max_length=100, blank=True, default="")
    our_silver_buy_rate = models.CharField(max_length=100, blank=True, default="")
    our_silver_sell_rate = models.CharField(max_length=100, blank=True, default="")
    rate_last_updated = models.CharField(max_length=100, blank=True, default="")
    rate_source_mode = models.CharField(
        max_length=20,
        choices=RATE_SOURCE_CHOICES,
        default="api",
        help_text="Choose whether live rates come from API or manual admin values.",
    )
    gold_buy_formula_operator = models.CharField(
        "Gold buy formula",
        max_length=1,
        choices=RATE_FORMULA_CHOICES,
        default="+",
        help_text="Formula applied to the displayed 10 gm Gold market rate for dealer buy.",
    )
    gold_buy_formula_value = models.FloatField(
        "Gold buy formula value",
        default=0.0,
        help_text="Value used by the Gold dealer buy formula.",
    )
    gold_formula_operator = models.CharField(
        "Gold sell formula",
        max_length=1,
        choices=RATE_FORMULA_CHOICES,
        default="+",
        help_text="Formula applied to the displayed 10 gm Gold market rate for dealer sell.",
    )
    gold_formula_value = models.FloatField(
        "Gold sell formula value",
        default=0.0,
        help_text="Value used by the Gold dealer sell formula.",
    )
    silver_buy_formula_operator = models.CharField(
        "Silver buy formula",
        max_length=1,
        choices=RATE_FORMULA_CHOICES,
        default="+",
        help_text="Formula applied to the displayed 10 gm Silver market rate for dealer buy.",
    )
    silver_buy_formula_value = models.FloatField(
        "Silver buy formula value",
        default=0.0,
        help_text="Value used by the Silver dealer buy formula.",
    )
    silver_formula_operator = models.CharField(
        "Silver sell formula",
        max_length=1,
        choices=RATE_FORMULA_CHOICES,
        default="+",
        help_text="Formula applied to the displayed 10 gm Silver market rate for dealer sell.",
    )
    silver_formula_value = models.FloatField(
        "Silver sell formula value",
        default=0.0,
        help_text="Value used by the Silver dealer sell formula.",
    )
    gold_display_multiplier = models.FloatField(default=1.0, help_text="Convert API gold gram price to display unit. Use 1 for gram rate.")
    silver_display_multiplier = models.FloatField(default=1.0, help_text="Convert API silver gram price to display unit. Use 1 for gram rate.")
    spread_pct = models.FloatField(default=0.5, help_text="Legacy/common spread percent (used if metal-specific spreads are empty).")
    gold_spread_pct = models.FloatField(default=0.16, help_text="Hybrid mode: gold buy/sell spread percent.")
    silver_spread_pct = models.FloatField(default=0.59, help_text="Hybrid mode: silver buy/sell spread percent.")
    factor_gold995 = models.FloatField(default=1.0)
    factor_silver_chorsa = models.FloatField(default=1.0)
    factor_silver_kacchi = models.FloatField(default=1.0)
    factor_gold999_gst_buy = models.FloatField(default=1.01)
    factor_gold999_gst_sell = models.FloatField(default=1.016)
    factor_gold_future_buy = models.FloatField(default=0.99)
    factor_gold_future_sell = models.FloatField(default=0.995)
    factor_silver_future_buy = models.FloatField(default=1.06)
    factor_silver_future_sell = models.FloatField(default=1.06)
    use_exact_table_rates = models.BooleanField(default=False, help_text="If enabled, table rows use exact admin values below.")
    row_gold995_buy = models.CharField(max_length=100, blank=True, default="")
    row_gold995_sell = models.CharField(max_length=100, blank=True, default="")
    row_gold995_low = models.CharField(max_length=100, blank=True, default="")
    row_gold995_high = models.CharField(max_length=100, blank=True, default="")
    row_silver_chorsa_buy = models.CharField(max_length=100, blank=True, default="")
    row_silver_chorsa_sell = models.CharField(max_length=100, blank=True, default="")
    row_silver_chorsa_low = models.CharField(max_length=100, blank=True, default="")
    row_silver_chorsa_high = models.CharField(max_length=100, blank=True, default="")
    row_silver_kacchi_buy = models.CharField(max_length=100, blank=True, default="")
    row_silver_kacchi_sell = models.CharField(max_length=100, blank=True, default="")
    row_silver_kacchi_low = models.CharField(max_length=100, blank=True, default="")
    row_silver_kacchi_high = models.CharField(max_length=100, blank=True, default="")
    row_gold999gst_buy = models.CharField(max_length=100, blank=True, default="")
    row_gold999gst_sell = models.CharField(max_length=100, blank=True, default="")
    row_gold999gst_low = models.CharField(max_length=100, blank=True, default="")
    row_gold999gst_high = models.CharField(max_length=100, blank=True, default="")
    row_goldfuture_buy = models.CharField(max_length=100, blank=True, default="")
    row_goldfuture_sell = models.CharField(max_length=100, blank=True, default="")
    row_goldfuture_low = models.CharField(max_length=100, blank=True, default="")
    row_goldfuture_high = models.CharField(max_length=100, blank=True, default="")
    row_silverfuture_buy = models.CharField(max_length=100, blank=True, default="")
    row_silverfuture_sell = models.CharField(max_length=100, blank=True, default="")
    row_silverfuture_low = models.CharField(max_length=100, blank=True, default="")
    row_silverfuture_high = models.CharField(max_length=100, blank=True, default="")
    gold_rtgs_buy_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    gold_rtgs_buy_value = models.FloatField(default=0.0)
    gold_rtgs_sell_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    gold_rtgs_sell_value = models.FloatField(default=0.0)
    silver_rtgs_buy_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_rtgs_buy_value = models.FloatField(default=0.0)
    silver_rtgs_sell_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_rtgs_sell_value = models.FloatField(default=0.0)
    silver_peti_rtgs_buy_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_peti_rtgs_buy_value = models.FloatField(default=0.0)
    silver_peti_rtgs_sell_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_peti_rtgs_sell_value = models.FloatField(default=0.0)
    gold_999_buy_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    gold_999_buy_value = models.FloatField(default=0.0)
    gold_999_sell_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    gold_999_sell_value = models.FloatField(default=0.0)
    gold_9950_buy_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    gold_9950_buy_value = models.FloatField(default=0.0)
    gold_9950_sell_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    gold_9950_sell_value = models.FloatField(default=0.0)
    silver_peti_tukda_buy_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_peti_tukda_buy_value = models.FloatField(default=0.0)
    silver_peti_tukda_sell_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_peti_tukda_sell_value = models.FloatField(default=0.0)
    silver_chorsa_99_buy_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_chorsa_99_buy_value = models.FloatField(default=0.0)
    silver_chorsa_99_sell_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_chorsa_99_sell_value = models.FloatField(default=0.0)
    silver_kacchi_50_90_buy_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_kacchi_50_90_buy_value = models.FloatField(default=0.0)
    silver_kacchi_50_90_sell_operator = models.CharField(max_length=1, choices=RATE_ADJUSTMENT_CHOICES, default="+")
    silver_kacchi_50_90_sell_value = models.FloatField(default=0.0)

    def __str__(self):
        return "Website Settings"

    class Meta:
        verbose_name_plural = "Website Settings"


class LiveRateSettings(WebsiteSettings):
    class Meta:
        proxy = True
        verbose_name = "Live Rate Adjustment"
        verbose_name_plural = "Live Rate Adjustments"


class OurRatesSettings(models.Model):
    RATE_FORMULA_CHOICES = WebsiteSettings.RATE_FORMULA_CHOICES

    gold_buy_formula_operator = models.CharField(
        "Gold buy formula",
        max_length=1,
        choices=RATE_FORMULA_CHOICES,
        default="+",
    )
    gold_buy_formula_value = models.FloatField("Gold buy formula value", default=0.0)
    gold_sell_formula_operator = models.CharField(
        "Gold sell formula",
        max_length=1,
        choices=RATE_FORMULA_CHOICES,
        default="+",
    )
    gold_sell_formula_value = models.FloatField("Gold sell formula value", default=0.0)
    silver_buy_formula_operator = models.CharField(
        "Silver buy formula",
        max_length=1,
        choices=RATE_FORMULA_CHOICES,
        default="+",
    )
    silver_buy_formula_value = models.FloatField("Silver buy formula value", default=0.0)
    silver_sell_formula_operator = models.CharField(
        "Silver sell formula",
        max_length=1,
        choices=RATE_FORMULA_CHOICES,
        default="+",
    )
    silver_sell_formula_value = models.FloatField("Silver sell formula value", default=0.0)

    def __str__(self):
        return "Our Rates Settings"

    class Meta:
        verbose_name = "Our Rates Settings"
        verbose_name_plural = "Our Rates Settings"

from django.db import models

class PageHeader(models.Model):
    PAGE_CHOICES = (
        ('about', 'About Page'),
        ('contact', 'Contact Page'),
        ('shop', 'Products Page'),
        ('bullion_rates', 'Live Rates Page'),
    )

    page = models.CharField(max_length=50, choices=PAGE_CHOICES, unique=True)
    title = models.CharField(max_length=200)
    subtitle = models.CharField(max_length=200, blank=True)
    background_image = models.ImageField(upload_to='page_headers/')

    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.page} Header"

from django.db import models


class AboutPage(models.Model):
    # PAGE HEADER
    header_title = models.CharField(max_length=200)
    header_subtitle = models.CharField(max_length=200)
    header_background = models.ImageField(upload_to="about/header/")

    # VISION
    vision_title = models.CharField(max_length=100, default="Our Vision")
    vision_text = models.TextField()

    # MISSION
    mission_title = models.CharField(max_length=100, default="Our Mission")
    mission_text = models.TextField()

    # WHO WE ARE
    who_title = models.CharField(max_length=100)
    who_subtitle = models.CharField(max_length=200)
    who_description = models.TextField()
    who_button_text = models.CharField(max_length=50)
    who_button_url = models.URLField()
    who_image_front = models.ImageField(upload_to="about/who/")
    who_image_back = models.ImageField(upload_to="about/who/")

    def __str__(self):
        return "About Page Content"

    class Meta:
        verbose_name = "About Page"
        verbose_name_plural = "About Page"


class Brand(models.Model):
    about_page = models.ForeignKey(AboutPage, on_delete=models.CASCADE, related_name="brands")
    name = models.CharField(max_length=100)
    logo = models.ImageField(upload_to="brands/")

    def __str__(self):
        return self.name


class Testimonial(models.Model):
    about_page = models.ForeignKey(AboutPage, on_delete=models.CASCADE, related_name="testimonials")
    name = models.CharField(max_length=100)
    role = models.CharField(max_length=100)
    message = models.TextField()
    photo = models.ImageField(upload_to="testimonials/")

    def __str__(self):
        return self.name


class ContactEnquiry(models.Model):
    ENQUIRY_TYPE_CHOICES = (
        ("jewellery", "Jewellery"),
        ("gold_bullion", "Gold Bullion"),
        ("silver_bullion", "Silver Bullion"),
        ("bulk_order", "Bulk Order"),
    )

    name = models.CharField(max_length=100)
    email = models.EmailField()
    phone = models.CharField(max_length=20, blank=True)
    enquiry_type = models.CharField(
        max_length=20,
        choices=ENQUIRY_TYPE_CHOICES,
        default="jewellery"
    )
    subject = models.CharField(max_length=200, blank=True)
    message = models.TextField()

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.email}"


class StoreLocation(models.Model):
    title = models.CharField(max_length=200)
    address = models.TextField()
    phone = models.CharField(max_length=20, blank=True)

    weekday_timing = models.CharField(
        max_length=100,
        help_text="Example: Monday - Saturday 11am to 7pm"
    )

    weekend_timing = models.CharField(
        max_length=100,
        blank=True,
        help_text="Example: Sunday 11am to 6pm / Closed"
    )

    image = models.ImageField(upload_to="stores/")
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.title

    class Meta:
        verbose_name = "Store Location"
        verbose_name_plural = "Store Locations"


# models.py

class HomeSlider(models.Model):
    title = models.CharField(
        max_length=200,
        blank=True,
        help_text="Optional (future use)"
    )
    image = models.ImageField(upload_to="home/slider/")
    link = models.URLField(
        blank=True,
        help_text="Image click URL (optional)"
    )
    position = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)

    class Meta:
        ordering = ["position"]
        verbose_name = "Home Slider"
        verbose_name_plural = "Home Sliders"

    def __str__(self):
        return f"Slider {self.position}"

# COMMUNITY SERVICE SECTION (HOME PAGE)

class CommunitySection(models.Model):
    title = models.CharField(
        max_length=200,
        default="Working for the Community"
    )
    subtitle = models.TextField(
        blank=True,
        help_text="Short description about social / community work"
    )
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.title

    class Meta:
        verbose_name = "Community Section"
        verbose_name_plural = "Community Section"


class CommunityGallery(models.Model):
    section = models.ForeignKey(
        CommunitySection,
        on_delete=models.CASCADE,
        related_name="images"
    )
    title = models.CharField(max_length=200, blank=True)
    image = models.ImageField(upload_to="community/")
    position = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.title or "Community Image"

    class Meta:
        ordering = ["position"]
        verbose_name = "Community Image"
        verbose_name_plural = "Community Images"


# PRODUCT CATEGORY

class ProductCategory(models.Model):
    title = models.CharField(max_length=100)
    subtitle = models.CharField(max_length=200, blank=True)
    banner_image = models.ImageField(upload_to="categories/banners/")
    slug = models.SlugField(unique=True)

    is_active = models.BooleanField(default=True)

    # 🔥 NEW FIELD (THIS IS THE KEY)
    show_on_home = models.BooleanField(
        default=False,
        help_text="Show this category on Home → Recent Arrivals"
    )

    position = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.title

    class Meta:
        ordering = ["position"]


class ProductSubCategory(models.Model):
    category = models.ForeignKey(
        ProductCategory,
        on_delete=models.CASCADE,
        related_name="subcategories"
    )
    title = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)
    is_active = models.BooleanField(default=True)
    position = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["position", "title"]

    def __str__(self):
        return f"{self.category.title} - {self.title}"


class Product(models.Model):
    METAL_CHOICES = (
        ("gold", "Gold"),
        ("silver", "Silver"),
        ("diamond", "Diamond"),
        ("platinum", "Platinum"),
        ("other", "Other"),
    )

    category = models.ForeignKey(
        ProductCategory,
        on_delete=models.CASCADE,
        related_name="products"
    )
    subcategory = models.ForeignKey(
        ProductSubCategory,
        on_delete=models.SET_NULL,
        related_name="products",
        blank=True,
        null=True
    )

    title = models.CharField(max_length=200)
    slug = models.SlugField(unique=True)

    price = models.DecimalField(max_digits=10, decimal_places=2)
    old_price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        blank=True,
        null=True
    )

    weight = models.DecimalField(
        max_digits=6,
        decimal_places=2,
        blank=True,
        null=True,
        help_text="Weight in KG"
    )

    is_in_stock = models.BooleanField(default=True)
    metal_type = models.CharField(max_length=20, choices=METAL_CHOICES, default="gold")
    purity = models.CharField(max_length=30, blank=True, help_text="e.g. 22K, 24K, 999")
    making_charges = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    hallmark = models.CharField(max_length=100, blank=True, help_text="e.g. BIS Hallmarked")

    description = models.TextField(blank=True)
    shipping_details = models.TextField(
        default="Shipping available all over India",
        blank=True
    )

    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class ProductImage(models.Model):
    product = models.ForeignKey(
        Product,
        on_delete=models.CASCADE,
        related_name="images"
    )
    image = models.ImageField(upload_to="products/gallery/")
    position = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["position"]

    def __str__(self):
        return f"{self.product.title} Image"

