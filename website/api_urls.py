from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from . import api_views

app_name = "website_api"

urlpatterns = [
    path("auth/signup-request/", api_views.AppSignupRequestView.as_view(), name="signup_request"),
    path("auth/signup-status/", api_views.AppSignupStatusView.as_view(), name="signup_status"),
    path("auth/login/", api_views.MobileLoginView.as_view(), name="login"),
    path("auth/forgot-password/", api_views.ForgotPasswordView.as_view(), name="forgot_password"),
    path("auth/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("profile/", api_views.ProfileView.as_view(), name="profile"),
    path("profile/update-request/", api_views.ProfileUpdateRequestView.as_view(), name="profile_update_request"),
    path("home/", api_views.AppHomeAPIView.as_view(), name="home"),
    path("about/", api_views.AppAboutAPIView.as_view(), name="about"),
    path("live-rates/", api_views.LiveRatesAPIView.as_view(), name="live_rates"),
    path("categories/", api_views.CategoryListAPIView.as_view(), name="categories"),
    path("products/", api_views.ProductListAPIView.as_view(), name="products"),
    path("products/<slug:slug>/", api_views.ProductDetailAPIView.as_view(), name="product_detail"),
    path("contact/", api_views.ContactAPIView.as_view(), name="contact"),
    path("privacy-policy/", api_views.PrivacyPolicyAPIView.as_view(), name="privacy_policy"),
]
