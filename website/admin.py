from django import forms
from django.contrib import admin
from .models import (
    WebsiteSettings,
    LiveRateSettings,
    OurRatesSettings,
    PageHeader,
    AboutPage,
    Brand,    Testimonial,
    ContactEnquiry,
    StoreLocation,
    HomeSlider,
)

# ============================================================
# WEBSITE SETTINGS (SINGLE INSTANCE)
# ============================================================

@admin.register(WebsiteSettings)
class WebsiteSettingsAdmin(admin.ModelAdmin):
    fieldsets = (
        ("Basic", {"fields": ("site_name", "tagline", "logo", "footer_logo")}),
        ("Contact", {"fields": (
            "phone",
            ("footer_phone_1", "footer_phone_2"),
            ("footer_phone_3", "footer_phone_4"),
            "email",
            "address",
        )}),
        ("Timing & Meta", {"fields": ("weekday_label", "weekday_time", "sunday_label", "sunday_time", "footer_text", "facebook", "instagram", "twitter", "youtube", "meta_keywords", "meta_description", "whatsapp_qr")}),
    )
    def has_add_permission(self, request):
        return not WebsiteSettings.objects.exists()


@admin.register(LiveRateSettings)
class LiveRateSettingsAdmin(admin.ModelAdmin):
    class LiveRateSettingsForm(forms.ModelForm):
        PRODUCT_LABELS = {
            "gold_rtgs": "Gold RTGS",
            "gold_999": "Gold 999",
            "gold_9950": "Gold 99.50",
            "silver_rtgs": "Silver RTGS",
            "silver_peti_rtgs": "Silver Peti RTGS",
            "silver_peti_tukda": "Silver Peti Tukda",
            "silver_chorsa_99": "Silver Chorsa 99",
            "silver_kacchi_50_90": "Silver Kacchi (50-90T)",
        }

        class Meta:
            model = LiveRateSettings
            fields = "__all__"

        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)
            for key, label in self.PRODUCT_LABELS.items():
                self.fields[f"{key}_buy_operator"].label = f"{label} buy adjustment"
                self.fields[f"{key}_buy_value"].label = f"{label} buy value"
                self.fields[f"{key}_sell_operator"].label = f"{label} sell adjustment"
                self.fields[f"{key}_sell_value"].label = f"{label} sell value"
                self.fields[f"{key}_buy_operator"].help_text = ""
                self.fields[f"{key}_buy_value"].help_text = ""
                self.fields[f"{key}_sell_operator"].help_text = ""
                self.fields[f"{key}_sell_value"].help_text = ""

    form = LiveRateSettingsForm
    fieldsets = (
        ("Visible Rows", {
            "description": "Turn rows on/off for the live rates table.",
            "fields": (
                "gold_rtgs_is_active",
                "gold_999_is_active",
                "gold_9950_is_active",
                "silver_rtgs_is_active",
                "silver_peti_rtgs_is_active",
                "silver_peti_tukda_is_active",
                "silver_chorsa_99_is_active",
                "silver_kacchi_50_90_is_active",
            ),
        }),
        ("Gold Rows", {
            "description": "These values are applied directly to fetched live Buy/Sell rates. Select Addition (+) or Subtraction (-), then enter the value.",
            "fields": (
                ("gold_rtgs_buy_operator", "gold_rtgs_buy_value"),
                ("gold_rtgs_sell_operator", "gold_rtgs_sell_value"),
                ("gold_999_buy_operator", "gold_999_buy_value"),
                ("gold_999_sell_operator", "gold_999_sell_value"),
                ("gold_9950_buy_operator", "gold_9950_buy_value"),
                ("gold_9950_sell_operator", "gold_9950_sell_value"),
            ),
        }),
        ("Silver Rows", {
            "description": "These values are applied directly to fetched live Buy/Sell rates. Select Addition (+) or Subtraction (-), then enter the value.",
            "fields": (
                ("silver_rtgs_buy_operator", "silver_rtgs_buy_value"),
                ("silver_rtgs_sell_operator", "silver_rtgs_sell_value"),
                ("silver_peti_rtgs_buy_operator", "silver_peti_rtgs_buy_value"),
                ("silver_peti_rtgs_sell_operator", "silver_peti_rtgs_sell_value"),
                ("silver_peti_tukda_buy_operator", "silver_peti_tukda_buy_value"),
                ("silver_peti_tukda_sell_operator", "silver_peti_tukda_sell_value"),
                ("silver_chorsa_99_buy_operator", "silver_chorsa_99_buy_value"),
                ("silver_chorsa_99_sell_operator", "silver_chorsa_99_sell_value"),
                ("silver_kacchi_50_90_buy_operator", "silver_kacchi_50_90_buy_value"),
                ("silver_kacchi_50_90_sell_operator", "silver_kacchi_50_90_sell_value"),
            ),
        }),
    )
    list_display = ("__str__", "gold_rtgs_preview", "silver_rtgs_preview", "active_rows_preview")

    @admin.display(description="Gold RTGS")
    def gold_rtgs_preview(self, obj):
        return f"Buy {obj.gold_rtgs_buy_operator}{obj.gold_rtgs_buy_value:g} / Sell {obj.gold_rtgs_sell_operator}{obj.gold_rtgs_sell_value:g}"

    @admin.display(description="Silver RTGS")
    def silver_rtgs_preview(self, obj):
        return f"Buy {obj.silver_rtgs_buy_operator}{obj.silver_rtgs_buy_value:g} / Sell {obj.silver_rtgs_sell_operator}{obj.silver_rtgs_sell_value:g}"

    @admin.display(description="Active rows")
    def active_rows_preview(self, obj):
        keys = self.LiveRateSettingsForm.PRODUCT_LABELS
        return sum(1 for key in keys if getattr(obj, f"{key}_is_active", True))

    def has_add_permission(self, request):
        return not WebsiteSettings.objects.exists()

    def has_delete_permission(self, request, obj=None):
        return False

    def get_queryset(self, request):
        return super().get_queryset(request).filter(pk=WebsiteSettings.objects.first().pk) if WebsiteSettings.objects.exists() else super().get_queryset(request).none()


@admin.register(OurRatesSettings)
class OurRatesSettingsAdmin(admin.ModelAdmin):
    fieldsets = (
        ("Gold Our Rates Formula", {"fields": (
            "gold_buy_formula_operator",
            "gold_buy_formula_value",
            "gold_sell_formula_operator",
            "gold_sell_formula_value",
        )}),
        ("Silver Our Rates Formula", {"fields": (
            "silver_buy_formula_operator",
            "silver_buy_formula_value",
            "silver_sell_formula_operator",
            "silver_sell_formula_value",
        )}),
    )

    def has_add_permission(self, request):
        return not OurRatesSettings.objects.exists()


# ============================================================
# PAGE HEADER (ABOUT / CONTACT / TEAM / SHOP)
# ============================================================

@admin.register(PageHeader)
class PageHeaderAdmin(admin.ModelAdmin):
    list_display = ("page", "title", "is_active")
    list_filter = ("page", "is_active")
    search_fields = ("title", "subtitle")


# ============================================================
# ABOUT PAGE INLINE MODELS
# ============================================================

class BrandInline(admin.TabularInline):
    model = Brand
    extra = 1


class TestimonialInline(admin.TabularInline):
    model = Testimonial
    extra = 1
    show_change_link = True


@admin.register(AboutPage)
class AboutPageAdmin(admin.ModelAdmin):
    inlines = [BrandInline, TestimonialInline]

    fieldsets = (
        ("Header Section", {
            "fields": ("header_title", "header_subtitle", "header_background")
        }),
        ("Vision Section", {
            "fields": ("vision_title", "vision_text")
        }),
        ("Mission Section", {
            "fields": ("mission_title", "mission_text")
        }),
        ("Who We Are Section", {
            "fields": (
                "who_title",
                "who_subtitle",
                "who_description",
                "who_button_text",
                "who_button_url",
                "who_image_front",
                "who_image_back",
            )
        }),
    )


# ============================================================
# TEAM MEMBERS (SIDE MENU + INLINE BOTH)
# ============================================================


# ============================================================
# TESTIMONIALS (SIDE MENU + INLINE BOTH)
# ============================================================

@admin.register(Testimonial)
class TestimonialAdmin(admin.ModelAdmin):
    list_display = ("name", "role", "about_page")
    search_fields = ("name", "role")
    list_select_related = ("about_page",)


# ============================================================
# CONTACT ENQUIRIES
# ============================================================

@admin.register(ContactEnquiry)
class ContactEnquiryAdmin(admin.ModelAdmin):
    list_display = ("name", "email", "phone", "enquiry_type", "subject", "created_at")
    search_fields = ("name", "email", "phone")
    list_filter = ("created_at",)


# ============================================================
# STORE LOCATIONS
# ============================================================

@admin.register(StoreLocation)
class StoreLocationAdmin(admin.ModelAdmin):
    list_display = ("title", "phone", "is_active")
    list_filter = ("is_active",)
    search_fields = ("title", "phone")


# ============================================================
# HOME SLIDER
# ============================================================

@admin.register(HomeSlider)
class HomeSliderAdmin(admin.ModelAdmin):
    list_display = ("id", "position", "is_active")
    list_editable = ("position", "is_active")
    ordering = ("position",)


from .models import CommunitySection, CommunityGallery


class CommunityGalleryInline(admin.TabularInline):
    model = CommunityGallery
    extra = 1
    fields = ("image", "title", "position", "is_active")
    ordering = ("position",)
    show_change_link = True


@admin.register(CommunitySection)
class CommunitySectionAdmin(admin.ModelAdmin):
    inlines = [CommunityGalleryInline]
    list_display = ("title", "is_active")


from .models import ProductCategory, ProductSubCategory

@admin.register(ProductCategory)
class ProductCategoryAdmin(admin.ModelAdmin):
    list_display = ("title", "is_active", "show_on_home", "position")
    list_editable = ("show_on_home", "position", "is_active")
    prepopulated_fields = {"slug": ("title",)}


@admin.register(ProductSubCategory)
class ProductSubCategoryAdmin(admin.ModelAdmin):
    list_display = ("title", "category", "is_active", "position")
    list_filter = ("category", "is_active")
    list_editable = ("is_active", "position")
    prepopulated_fields = {"slug": ("title",)}


from .models import Product
from .models import ProductImage

class ProductImageInline(admin.TabularInline):
    model = ProductImage
    extra = 1

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ("title", "category", "subcategory", "metal_type", "purity", "price", "is_in_stock", "is_active")
    list_filter = ("category", "subcategory", "metal_type", "purity", "is_in_stock", "is_active")
    prepopulated_fields = {"slug": ("title",)}
    inlines = [ProductImageInline]








