from django import forms
from django.contrib import admin
from django.contrib.auth.models import User
from django.utils import timezone
from .models import (
    WebsiteSettings,
    LiveRateSettings,
    OurRatesSettings,
    PageHeader,
    AboutPage,
    Brand,    Testimonial,
    ContactEnquiry,
    AppSignupRequest,
    AppProfileUpdateRequest,
    StoreLocation,
    HomeSlider,
)
from .push_notifications import send_account_approved_notification

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
        ("Live Rates API", {"fields": ("goldrates_cloud_api_url", "goldrates_cloud_api_key")}),
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
        ("GoldRates Cloud API", {
            "description": "Change the live-rate API endpoint or key here. These admin values override .env/settings.py when filled.",
            "fields": (
                "goldrates_cloud_api_url",
                "goldrates_cloud_api_key",
            ),
        }),
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


@admin.register(AppSignupRequest)
class AppSignupRequestAdmin(admin.ModelAdmin):
    list_display = ("name", "mobile", "status", "created_at", "reviewed_at")
    list_filter = ("status", "created_at", "reviewed_at")
    search_fields = ("name", "mobile", "email")
    readonly_fields = ("password_hash", "fcm_token", "created_at", "reviewed_at")
    actions = ("approve_requests", "reject_requests")
    fieldsets = (
        ("Customer", {"fields": ("name", "mobile", "profile_image", "message")}),
        ("Review", {"fields": ("status", "admin_note", "reviewed_at")}),
        ("Push Notification", {"fields": ("fcm_token",)}),
        ("System", {"fields": ("password_hash", "created_at")}),
    )

    @admin.action(description="Approve selected signup requests")
    def approve_requests(self, request, queryset):
        approved = 0
        for signup in queryset:
            if self._approve_signup(signup):
                approved += 1
        self.message_user(request, f"{approved} signup request(s) approved.")

    def save_model(self, request, obj, form, change):
        was_approved = False
        if change and obj.pk:
            was_approved = AppSignupRequest.objects.filter(
                pk=obj.pk,
                status=AppSignupRequest.STATUS_APPROVED,
            ).exists()

        if obj.status == AppSignupRequest.STATUS_APPROVED and not was_approved:
            self._approve_signup(obj)
            return
        super().save_model(request, obj, form, change)

    def _approve_signup(self, signup):
        if signup.status == AppSignupRequest.STATUS_APPROVED and signup.reviewed_at:
            return False

        user, created = User.objects.get_or_create(
            username=signup.mobile,
            defaults={
                "first_name": signup.name,
                "email": signup.email,
                "password": signup.password_hash,
                "is_active": True,
            },
        )
        if not created:
            user.first_name = signup.name
            user.email = signup.email
            user.password = signup.password_hash
            user.is_active = True
            user.save(update_fields=["first_name", "email", "password", "is_active"])
        signup.status = AppSignupRequest.STATUS_APPROVED
        signup.reviewed_at = signup.reviewed_at or timezone.now()
        signup.save()
        send_account_approved_notification(signup.fcm_token)
        return True

    @admin.action(description="Reject selected signup requests")
    def reject_requests(self, request, queryset):
        updated = queryset.update(
            status=AppSignupRequest.STATUS_REJECTED,
            reviewed_at=timezone.now(),
        )
        self.message_user(request, f"{updated} signup request(s) rejected.")


@admin.register(AppProfileUpdateRequest)
class AppProfileUpdateRequestAdmin(admin.ModelAdmin):
    list_display = ("user", "name", "mobile", "city", "status", "created_at", "reviewed_at")
    list_filter = ("status", "created_at", "reviewed_at")
    search_fields = ("user__username", "name", "mobile", "city")
    actions = ("approve_requests", "reject_requests")
    fieldsets = (
        ("Requested Details", {"fields": ("user", "name", "mobile", "city", "message")}),
        ("Review", {"fields": ("status", "admin_note", "reviewed_at")}),
    )

    @admin.action(description="Approve selected profile update requests")
    def approve_requests(self, request, queryset):
        count = 0
        for update in queryset:
            if self._approve_update(update):
                count += 1
        self.message_user(request, f"{count} profile update request(s) approved.")

    def save_model(self, request, obj, form, change):
        was_approved = False
        if change and obj.pk:
            was_approved = AppProfileUpdateRequest.objects.filter(
                pk=obj.pk,
                status=AppProfileUpdateRequest.STATUS_APPROVED,
            ).exists()
        if obj.status == AppProfileUpdateRequest.STATUS_APPROVED and not was_approved:
            self._approve_update(obj)
            return
        super().save_model(request, obj, form, change)

    def _approve_update(self, update):
        if update.status == AppProfileUpdateRequest.STATUS_APPROVED and update.reviewed_at:
            return False
        user = update.user
        old_mobile = user.username
        user.username = update.mobile
        user.first_name = update.name
        user.save(update_fields=["username", "first_name"])
        signup = AppSignupRequest.objects.filter(mobile=old_mobile).first()
        if signup:
            signup.name = update.name
            signup.mobile = update.mobile
            signup.city = update.city
            signup.save(update_fields=["name", "mobile", "city"])
        update.status = AppProfileUpdateRequest.STATUS_APPROVED
        update.reviewed_at = timezone.now()
        update.save(update_fields=["status", "reviewed_at"])
        return True

    @admin.action(description="Reject selected profile update requests")
    def reject_requests(self, request, queryset):
        updated = queryset.update(
            status=AppProfileUpdateRequest.STATUS_REJECTED,
            reviewed_at=timezone.now(),
        )
        self.message_user(request, f"{updated} profile update request(s) rejected.")


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








