import re

from django.conf import settings
from django.core.cache import cache

from .models import WebsiteSettings

def website_settings(request):
    site = WebsiteSettings.objects.first()
    whatsapp_phone = getattr(settings, "WHATSAPP_PHONE", "")
    footer_phone_numbers = []
    if site and site.phone:
        whatsapp_phone = re.sub(r"\D", "", site.phone) or whatsapp_phone
    if site:
        footer_phone_numbers = [
            number for number in [
                site.footer_phone_1,
                site.footer_phone_2,
                site.footer_phone_3,
                site.footer_phone_4,
            ]
            if number
        ]
        if not footer_phone_numbers and site.phone:
            footer_phone_numbers = [site.phone]
    return {
        "site": site,
        "whatsapp_phone": whatsapp_phone,
        "footer_phone_numbers": footer_phone_numbers,
    }

from .models import ProductCategory

def shop_menu(request):
    return {
        "menu_categories": ProductCategory.objects.filter(
            is_active=True
        ).order_by("position")
    }


def rate_ticker(request):
    cache_key = "website:rate_ticker_rows"
    cached = cache.get(cache_key)
    if cached is None:
        try:
            from .views import get_bullion_rate_rows
            rows, source, updated = get_bullion_rate_rows(WebsiteSettings.objects.first())
        except Exception:
            rows, source, updated = [], "", ""
        cached = (rows, source, updated)
        cache.set(cache_key, cached, 300)
    rows, source, updated = cached
    return {
        "rate_ticker_rows": rows,
        "rate_ticker_source": source,
        "rate_ticker_updated": updated,
    }
