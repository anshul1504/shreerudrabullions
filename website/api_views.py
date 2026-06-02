from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.hashers import make_password
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError as DjangoValidationError
from rest_framework import serializers, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.parsers import MultiPartParser, FormParser

from .models import (
    AboutPage,
    AppSignupRequest,
    AppProfileUpdateRequest,
    ContactEnquiry,
    HomeSlider,
    Product,
    ProductCategory,
    WebsiteSettings,
)
from .views import (
    _fetch_market_bullion_rates,
    get_bullion_rate_rows,
    get_market_base_rates,
    get_market_summary,
    get_our_rate_rows,
)


def _absolute_image_url(request, image):
    if not image:
        return ""
    try:
        return request.build_absolute_uri(image.url)
    except ValueError:
        return ""


class SignupRequestSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100)
    mobile = serializers.CharField(max_length=20)
    password = serializers.CharField(min_length=6, max_length=128, write_only=True)
    confirm_password = serializers.CharField(min_length=6, max_length=128, write_only=True)
    message = serializers.CharField(required=False, allow_blank=True)
    fcm_token = serializers.CharField(required=False, allow_blank=True)

    def validate_name(self, value):
        value = value.strip()
        if len(value) < 3:
            raise serializers.ValidationError("Enter your full name.")
        return value

    def validate_mobile(self, value):
        mobile = "".join(ch for ch in value if ch.isdigit())
        if mobile.startswith("91") and len(mobile) == 12:
            mobile = mobile[2:]
        if len(mobile) != 10 or mobile[0] not in "6789":
            raise serializers.ValidationError("Enter a valid 10 digit Indian mobile number.")
        if User.objects.filter(username=mobile).exists():
            raise serializers.ValidationError("This mobile number is already approved. Please login.")
        if AppSignupRequest.objects.filter(mobile=mobile, status=AppSignupRequest.STATUS_PENDING).exists():
            raise serializers.ValidationError("A signup request for this mobile number is already pending.")
        return mobile

    def validate(self, attrs):
        if attrs["password"] != attrs["confirm_password"]:
            raise serializers.ValidationError({"confirm_password": "Password and confirm password must match."})
        try:
            validate_password(attrs["password"])
        except DjangoValidationError as exc:
            raise serializers.ValidationError({"password": list(exc.messages)})
        return attrs


class AppSignupRequestView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = SignupRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        signup = AppSignupRequest.objects.create(
            name=data["name"],
            mobile=data["mobile"],
            fcm_token=data.get("fcm_token", ""),
            password_hash=make_password(data["password"]),
            message=data.get("message", ""),
        )
        return Response(
            {
                "id": signup.id,
                "status": signup.status,
                "message": "Your request has been submitted successfully. Our team will review your details and get back to you within 24-48 hours.",
            },
            status=status.HTTP_201_CREATED,
        )


class AppSignupStatusView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        mobile = "".join(ch for ch in str(request.query_params.get("mobile", "")) if ch.isdigit())
        if mobile.startswith("91") and len(mobile) == 12:
            mobile = mobile[2:]
        if len(mobile) != 10:
            return Response({"detail": "Enter a valid mobile number."}, status=status.HTTP_400_BAD_REQUEST)
        try:
            signup = AppSignupRequest.objects.get(mobile=mobile)
        except AppSignupRequest.DoesNotExist:
            if User.objects.filter(username=mobile, is_active=True).exists():
                return Response(
                    {
                        "mobile": mobile,
                        "status": AppSignupRequest.STATUS_APPROVED,
                        "message": "Your account is approved. Please login.",
                    }
                )
            return Response({"detail": "Signup request not found."}, status=status.HTTP_404_NOT_FOUND)
        messages = {
            AppSignupRequest.STATUS_PENDING: "Your request is currently under review. Our team will get back to you within 24-48 hours.",
            AppSignupRequest.STATUS_APPROVED: "Your account has been approved. You can now log in with your mobile number and password.",
            AppSignupRequest.STATUS_REJECTED: "Your request was rejected. Please contact support.",
        }
        return Response(
            {
                "mobile": mobile,
                "status": signup.status,
                "message": messages.get(signup.status, "Signup request status updated."),
            }
        )


class MobileLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        mobile = "".join(ch for ch in str(request.data.get("mobile", "")) if ch.isdigit())
        if mobile.startswith("91") and len(mobile) == 12:
            mobile = mobile[2:]
        password = request.data.get("password", "")
        user = authenticate(request, username=mobile, password=password)
        if not user:
            return Response(
                {"detail": "Invalid mobile number or password."},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        if not user.is_active:
            return Response(
                {"detail": "Your account is not active yet."},
                status=status.HTTP_403_FORBIDDEN,
            )
        refresh = RefreshToken.for_user(user)
        return Response(
            {
                "access": str(refresh.access_token),
                "refresh": str(refresh),
                "user": {
                    "id": user.id,
                    "name": user.get_full_name() or user.first_name or user.username,
                    "mobile": user.username,
                },
            }
        )


class ForgotPasswordView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        mobile = "".join(ch for ch in str(request.data.get("mobile", "")) if ch.isdigit())
        if mobile.startswith("91") and len(mobile) == 12:
            mobile = mobile[2:]
        password = str(request.data.get("password", ""))
        confirm_password = str(request.data.get("confirm_password", ""))
        if len(mobile) != 10:
            return Response({"detail": "Enter a valid 10 digit mobile number."}, status=status.HTTP_400_BAD_REQUEST)
        if password != confirm_password:
            return Response({"detail": "Password and confirm password must match."}, status=status.HTTP_400_BAD_REQUEST)
        try:
            validate_password(password)
        except DjangoValidationError as exc:
            return Response({"detail": " ".join(exc.messages)}, status=status.HTTP_400_BAD_REQUEST)
        try:
            signup = AppSignupRequest.objects.get(mobile=mobile, status=AppSignupRequest.STATUS_APPROVED)
        except AppSignupRequest.DoesNotExist:
            return Response({"detail": "Approved account not found for this mobile number."}, status=status.HTTP_404_NOT_FOUND)
        user = User.objects.filter(username=mobile, is_active=True).first()
        if not user:
            return Response({"detail": "Active user account not found."}, status=status.HTTP_404_NOT_FOUND)
        user.set_password(password)
        user.save(update_fields=["password"])
        signup.password_hash = user.password
        signup.save(update_fields=["password_hash"])
        return Response({"message": "Password reset ho gaya hai. Ab aap login kar sakte hain."})


class AppHomeAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        site = WebsiteSettings.objects.first()
        sliders = HomeSlider.objects.filter(is_active=True).order_by("position")
        all_categories = ProductCategory.objects.filter(is_active=True).order_by("position")
        products = Product.objects.filter(is_active=True).select_related("category").order_by("-created_at", "-id")[:12]
        about = AboutPage.objects.prefetch_related("testimonials").first()
        return Response(
            {
                "site_name": site.site_name if site else "Shree Rudra Bullion",
                "tagline": site.tagline if site else "",
                "logo": _absolute_image_url(request, site.logo if site else None),
                "phone": site.phone if site else "",
                "address": site.address if site else "",
                "footer_text": site.footer_text if site else "",
                "weekday_label": site.weekday_label if site else "",
                "weekday_time": site.weekday_time if site else "",
                "sunday_label": site.sunday_label if site else "",
                "sunday_time": site.sunday_time if site else "",
                "sliders": [
                    {
                        "title": slide.title,
                        "image": _absolute_image_url(request, slide.image),
                        "link": slide.link,
                    }
                    for slide in sliders
                ],
                "categories": [
                    {
                        "id": category.id,
                        "title": category.title,
                        "subtitle": category.subtitle,
                        "slug": category.slug,
                        "image": _absolute_image_url(request, category.banner_image),
                    }
                    for category in all_categories
                ],
                "products": [
                    {
                        "id": product.id,
                        "title": product.title,
                        "slug": product.slug,
                        "category": product.category.title if product.category else "",
                        "price": str(product.price),
                        "old_price": str(product.old_price) if product.old_price else "",
                        "image": _absolute_image_url(request, product.images.first().image if product.images.exists() else None),
                    }
                    for product in products
                ],
                "testimonials": [
                    {
                        "name": testimonial.name,
                        "role": testimonial.role,
                        "message": testimonial.message,
                        "photo": _absolute_image_url(request, testimonial.photo),
                    }
                    for testimonial in about.testimonials.all()
                ] if about else [],
            }
        )


class AppAboutAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        about = AboutPage.objects.prefetch_related("testimonials", "brands").first()
        if not about:
            return Response(
                {
                    "header_title": "About Us",
                    "header_subtitle": "",
                    "header_background": "",
                    "vision_title": "",
                    "vision_text": "",
                    "mission_title": "",
                    "mission_text": "",
                    "who_title": "",
                    "who_subtitle": "",
                    "who_description": "",
                    "who_button_text": "",
                    "who_button_url": "",
                    "who_image": "",
                    "brands": [],
                    "testimonials": [],
                }
            )
        return Response(
            {
                "header_title": about.header_title,
                "header_subtitle": about.header_subtitle,
                "header_background": _absolute_image_url(request, about.header_background),
                "vision_title": about.vision_title,
                "vision_text": about.vision_text,
                "mission_title": about.mission_title,
                "mission_text": about.mission_text,
                "who_title": about.who_title,
                "who_subtitle": about.who_subtitle,
                "who_description": about.who_description,
                "who_button_text": about.who_button_text,
                "who_button_url": about.who_button_url,
                "who_image": _absolute_image_url(request, about.who_image_back),
                "brands": [
                    {
                        "name": brand.name,
                        "logo": _absolute_image_url(request, brand.logo),
                    }
                    for brand in about.brands.all()
                ],
                "testimonials": [
                    {
                        "name": testimonial.name,
                        "role": testimonial.role,
                        "message": testimonial.message,
                        "photo": _absolute_image_url(request, testimonial.photo),
                    }
                    for testimonial in about.testimonials.all()
                ],
            }
        )


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        signup = AppSignupRequest.objects.filter(mobile=user.username).first()
        return Response(
            {
                "id": user.id,
                "name": user.get_full_name() or user.first_name or user.username,
                "mobile": user.username,
                "profile_image": _absolute_image_url(request, signup.profile_image if signup else None),
            }
        )

    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        signup = AppSignupRequest.objects.filter(mobile=request.user.username).first()
        if not signup:
            return Response({"detail": "Profile record not found."}, status=status.HTTP_404_NOT_FOUND)
        image = request.FILES.get("profile_image")
        if not image:
            return Response({"detail": "Profile image is required."}, status=status.HTTP_400_BAD_REQUEST)
        signup.profile_image = image
        signup.save(update_fields=["profile_image"])
        return Response({"message": "Profile image updated.", "profile_image": _absolute_image_url(request, signup.profile_image)})


class ProfileUpdateRequestView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        name = str(request.data.get("name", "")).strip()
        mobile = "".join(ch for ch in str(request.data.get("mobile", "")) if ch.isdigit())
        if mobile.startswith("91") and len(mobile) == 12:
            mobile = mobile[2:]
        city = str(request.data.get("city", "")).strip()
        message = str(request.data.get("message", "")).strip()
        if len(name) < 3:
            return Response({"detail": "Enter your full name."}, status=status.HTTP_400_BAD_REQUEST)
        if len(mobile) != 10 or mobile[0] not in "6789":
            return Response({"detail": "Enter a valid 10 digit mobile number."}, status=status.HTTP_400_BAD_REQUEST)
        AppProfileUpdateRequest.objects.create(
            user=request.user,
            name=name,
            mobile=mobile,
            city=city,
            message=message,
        )
        return Response({"message": "Your profile changes have been submitted for admin approval."}, status=status.HTTP_201_CREATED)


class LiveRatesAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        site = WebsiteSettings.objects.first()
        market = _fetch_market_bullion_rates()
        rate_rows, rate_source, rate_updated = get_bullion_rate_rows(site, market)
        return Response(
            {
                "market_open": market.get("market_open", False),
                "rate_source": rate_source,
                "rate_updated": rate_updated,
                "market_summary": get_market_summary(market),
                "market_base_rates": get_market_base_rates(market),
                "rows": get_our_rate_rows(rate_rows, settings_obj=True),
            }
        )


class ProductListAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        products = Product.objects.filter(is_active=True).select_related("category", "subcategory").order_by("-created_at", "-id")
        data = []
        for product in products:
            data.append(
                {
                    "id": product.id,
                    "title": product.title,
                    "slug": product.slug,
                    "category": product.category.title if product.category else "",
                    "subcategory": product.subcategory.title if product.subcategory else "",
                    "metal_type": product.metal_type,
                    "purity": product.purity,
                    "price": str(product.price),
                    "old_price": str(product.old_price) if product.old_price else "",
                    "weight": str(product.weight) if product.weight else "",
                    "is_in_stock": product.is_in_stock,
                    "image": _absolute_image_url(request, product.images.first().image if product.images.exists() else None),
                }
            )
        return Response({"products": data})


class ProductDetailAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, slug):
        try:
            product = Product.objects.select_related("category", "subcategory").get(slug=slug, is_active=True)
        except Product.DoesNotExist:
            return Response({"detail": "Product not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(
            {
                "id": product.id,
                "title": product.title,
                "slug": product.slug,
                "category": product.category.title if product.category else "",
                "subcategory": product.subcategory.title if product.subcategory else "",
                "metal_type": product.metal_type,
                "purity": product.purity,
                "price": str(product.price),
                "old_price": str(product.old_price) if product.old_price else "",
                "weight": str(product.weight) if product.weight else "",
                "making_charges": str(product.making_charges) if product.making_charges else "",
                "hallmark": product.hallmark,
                "description": product.description,
                "shipping_details": product.shipping_details,
                "is_in_stock": product.is_in_stock,
                "images": [
                    _absolute_image_url(request, image.image)
                    for image in product.images.all()
                ],
            }
        )


class CategoryListAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        categories = ProductCategory.objects.filter(is_active=True).order_by("position")
        return Response(
            {
                "categories": [
                    {
                        "id": category.id,
                        "title": category.title,
                        "subtitle": category.subtitle,
                        "slug": category.slug,
                        "image": _absolute_image_url(request, category.banner_image),
                    }
                    for category in categories
                ]
            }
        )


class ContactAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        site = WebsiteSettings.objects.first()
        return Response(
            {
                "phone": site.phone if site else "",
                "email": site.email if site else "",
                "address": site.address if site else "",
                "footer_phone_numbers": [
                    number
                    for number in [
                        site.footer_phone_1 if site else "",
                        site.footer_phone_2 if site else "",
                        site.footer_phone_3 if site else "",
                        site.footer_phone_4 if site else "",
                    ]
                    if number
                ],
            }
        )

    def post(self, request):
        ContactEnquiry.objects.create(
            name=request.data.get("name") or request.user.first_name or request.user.username,
            email=request.data.get("email", ""),
            phone=request.data.get("phone") or request.user.username,
            enquiry_type=request.data.get("enquiry_type", "gold_bullion"),
            subject=request.data.get("subject", "App enquiry"),
            message=request.data.get("message", ""),
        )
        return Response({"message": "Your enquiry has been submitted."}, status=status.HTTP_201_CREATED)


class PrivacyPolicyAPIView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response(
            {
                "title": "Privacy Policy",
                "effective_date": "May 5, 2026",
                "content": "Shree Rudra Bullion & Jewels is committed to protecting your privacy and handling personal information responsibly. Please contact us for privacy-related questions or requests.",
            }
        )
