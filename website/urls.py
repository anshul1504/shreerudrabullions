from django.urls import path
from . import views

app_name = "website"

urlpatterns = [
    path("", views.bullion_rates, name="bullion_rates_home"),
    path("home/", views.home, name="home"),
    path("bullion-rates/", views.bullion_rates, name="bullion_rates"),
    path("bullion-rates/data/", views.bullion_rates_data, name="bullion_rates_data"),
    path("faq/", views.faq_page, name="faq"),
    path("privacy-policy/", views.privacy_policy, name="privacy_policy"),
    path("about/", views.about, name="about"),
    path("contact/", views.contact, name="contact"),
    path("shop/", views.shop, name="shop"),

    # ✅ CATEGORY LIST (NO SLUG)
    path("category/", views.category_list, name="category_list"),

    # ✅ CATEGORY DETAIL (WITH SLUG)
    path("category/<slug:slug>/", views.category_detail, name="category"),

    # PRODUCT
    path("product/<slug:slug>/", views.product_detail, name="product_detail"),
]
