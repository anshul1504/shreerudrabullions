from django.shortcuts import render, redirect
from django.http import JsonResponse
from urllib.parse import urlencode
import json
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen
from django.conf import settings
from django.core.exceptions import ValidationError

from .models import (
    ProductCategory,
    WebsiteSettings,
    OurRatesSettings,
    PageHeader,
    AboutPage,
    ContactEnquiry,
    HomeSlider,
    CommunitySection,
    StoreLocation,
)



# =========================
# HOME PAGE
# =========================
from .models import Product

def home(request):
    sliders = HomeSlider.objects.filter(is_active=True).order_by("position")

    about = AboutPage.objects.first()
    testimonials = about.testimonials.all() if about else []

    community = CommunitySection.objects.filter(is_active=True).first()

    # ✅ 1. ALL categories → for carousel
    all_categories = ProductCategory.objects.filter(
        is_active=True
    ).order_by("position")

    # ✅ 2. ONLY selected categories → for tabs
    home_categories = ProductCategory.objects.filter(
        is_active=True,
        show_on_home=True
    ).order_by("position")

    # ✅ products for ALL tab
    products = Product.objects.filter(is_active=True).order_by("-created_at", "-id")

    return render(request, "website/index.html", {
        "sliders": sliders,
        "about": about,
        "home_testimonials": testimonials,
        "community": community,

        # 🔥 IMPORTANT
        "all_categories": all_categories,      # carousel
        "categories": home_categories,          # tabs
        "products": products,
    })

# =========================
# ABOUT PAGE
# =========================
def about(request):
    header = PageHeader.objects.filter(
        page='about',
        is_active=True
    ).first()

    about = AboutPage.objects.first()

    context = {
        "header": header,
        "about": about,
        "brands": about.brands.all() if about else [],
        "testimonials": about.testimonials.all() if about else [],
    }

    return render(request, "website/about.html", context)


# =========================
# CONTACT PAGE
# =========================
from .models import StoreLocation

def contact(request):
    header = PageHeader.objects.filter(
        page='contact',
        is_active=True
    ).first()

    if request.method == "POST":
        ContactEnquiry.objects.create(
            name=request.POST.get("name"),
            email=request.POST.get("email"),
            phone=request.POST.get("phone"),
            enquiry_type=request.POST.get("enquiry_type", "jewellery"),
            subject=request.POST.get("subject"),
            message=request.POST.get("message"),
        )
        params = urlencode({"submitted": "1"})
        return redirect(f"{request.path}?{params}")

    stores = StoreLocation.objects.filter(is_active=True)

    return render(request, "website/contact.html", {
        "header": header,
        "stores": stores,
    })

# =========================
# SHOP / CATEGORY (STATIC FOR NOW)
# =========================
def shop(request):
    # Keep legacy /shop/ URL working by serving the maintained category listing.
    return category_list(request)

from django.shortcuts import render, get_object_or_404
from django.db.models import Count, Q
from .models import Product, ProductCategory, PageHeader, ProductSubCategory


from django.core.paginator import Paginator


def _apply_product_filters(products, params):
    min_price = params.get("min_price")
    max_price = params.get("max_price")
    weight = params.get("weight")
    availability = params.get("availability")
    metal_type = params.get("metal_type")
    purity = params.get("purity")
    subcategory = params.get("subcategory")

    def safe_filter(queryset, **kwargs):
        try:
            return queryset.filter(**kwargs)
        except (TypeError, ValueError, ValidationError):
            return queryset.none()

    if min_price:
        products = safe_filter(products, price__gte=min_price)
    if max_price:
        products = safe_filter(products, price__lte=max_price)
    if weight:
        products = safe_filter(products, weight__gte=weight)
    if availability == "in":
        products = products.filter(is_in_stock=True)
    if metal_type:
        products = products.filter(metal_type=metal_type)
    if purity:
        products = products.filter(purity__iexact=purity)
    if subcategory:
        products = products.filter(subcategory__slug=subcategory)
    return products

def category_list(request):
    header = PageHeader.objects.filter(page="shop", is_active=True).first()

    products = Product.objects.filter(is_active=True)

    products = _apply_product_filters(products, request.GET).order_by("-created_at", "-id")
    paginator = Paginator(products, 9)  # 9 products per page
    page_number = request.GET.get("page")
    page_obj = paginator.get_page(page_number)

    categories = ProductCategory.objects.filter(is_active=True).annotate(
        product_count=Count("products", filter=Q(products__is_active=True))
    )
    subcategories = ProductSubCategory.objects.filter(is_active=True)

    return render(request, "website/category.html", {
        "header": header,
        "products": page_obj,
        "categories": categories,
        "active_category": None,
        "subcategories": subcategories,
        "page_obj": page_obj,
    })


def _format_indian_rate(value):
    if value is None:
        return ""
    rounded = int(round(value))
    sign = "-" if rounded < 0 else ""
    digits = str(abs(rounded))
    if len(digits) <= 3:
        return f"{sign}{digits}"
    last_three = digits[-3:]
    rest = digits[:-3]
    groups = []
    while len(rest) > 2:
        groups.insert(0, rest[-2:])
        rest = rest[:-2]
    if rest:
        groups.insert(0, rest)
    return f"{sign}{','.join(groups + [last_three])}"


def _format_decimal_rate(value, places=2):
    if value is None:
        return ""
    return f"{value:.{places}f}"


def _rate_midpoint(row):
    bid = _to_float(row.get("bid"))
    ask = _to_float(row.get("ask"))
    if bid is not None and ask is not None:
        return (bid + ask) / 2
    return bid if bid is not None else ask


def _spread_pair(base_rate, spread_pct):
    if base_rate is None:
        return None, None
    spread = base_rate * (spread_pct / 100)
    return base_rate - spread, base_rate + spread


def _apply_rate_formula(base_rate, operator, value):
    if base_rate is None:
        return None
    formula_value = _to_float(value)
    if formula_value is None:
        formula_value = 0
    if operator == "-":
        return base_rate - formula_value
    if operator == "*":
        return base_rate * formula_value
    if operator == "/":
        return base_rate / formula_value if formula_value else base_rate
    if operator == "%":
        return base_rate + (base_rate * formula_value / 100)
    return base_rate + formula_value


def _formula_text(operator, value):
    formula_value = _to_float(value)
    if formula_value is None:
        formula_value = 0
    if operator == "%":
        return f"+ {formula_value:g}%"
    if operator in {"-", "*", "/"}:
        return f"{operator} {formula_value:g}"
    return f"+ {formula_value:g}"


def _fetch_market_bullion_rates():
    gold_10gm = None
    silver_1kg = None
    gold_high = None
    gold_low = None
    gold_buy = None
    gold_sell = None
    silver_high = None
    silver_low = None
    silver_buy = None
    silver_sell = None
    usd_inr = None
    gold_usd = None
    silver_usd = None
    source = ""
    updated = ""
    market_open = False

    site_settings = WebsiteSettings.objects.first()
    cloud_url = (
        getattr(site_settings, "goldrates_cloud_api_url", "").strip()
        if site_settings
        else ""
    ) or getattr(settings, "BULLION_GOLDRATES_CLOUD_API_URL", "").strip()
    cloud_key = (
        getattr(site_settings, "goldrates_cloud_api_key", "").strip()
        if site_settings
        else ""
    ) or getattr(settings, "BULLION_GOLDRATES_CLOUD_API_KEY", "").strip()
    if cloud_url and cloud_key:
        try:
            params = urlencode({"api_key": cloud_key})
            sep = "&" if "?" in cloud_url else "?"
            request = Request(f"{cloud_url}{sep}{params}", headers={"User-Agent": "ShreeRudraBullion/1.0"})
            with urlopen(request, timeout=8) as response:
                payload = json.loads(response.read().decode("utf-8"))
            rows = payload.get("data", []) if isinstance(payload, dict) else []
            by_symbol = {
                str(row.get("symbol", "")).strip().upper(): row
                for row in rows
                if isinstance(row, dict)
            }
            gold_row = by_symbol.get("GOLD COSTING", {})
            silver_row = by_symbol.get("SILVER COSTING", {})
            usd_row = by_symbol.get("INR", {})
            gold_usd_row = by_symbol.get("GOLD($)", {})
            silver_usd_row = by_symbol.get("SILVER($)", {})
            gold_buy = _to_float(gold_row.get("bid"))
            gold_sell = _to_float(gold_row.get("ask"))
            silver_buy = _to_float(silver_row.get("bid"))
            silver_sell = _to_float(silver_row.get("ask"))
            market_open = any(
                value is not None
                for value in (gold_buy, gold_sell, silver_buy, silver_sell)
            )
            usd_inr = _rate_midpoint(usd_row)
            gold_usd = _rate_midpoint(gold_usd_row)
            silver_usd = _rate_midpoint(silver_usd_row)
            gold_10gm = _rate_midpoint(gold_row)
            silver_1kg = _rate_midpoint(silver_row)
            gold_high = _to_float(gold_row.get("high"))
            gold_low = _to_float(gold_row.get("low"))
            silver_high = _to_float(silver_row.get("high"))
            silver_low = _to_float(silver_row.get("low"))
            if gold_10gm or silver_1kg:
                source = "GoldRates Cloud"
                updated = payload.get("date", "")
        except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError):
            pass

    if getattr(settings, "BULLION_GOLDAPI_KEY", "").strip():
        try:
            headers = {
                "x-access-token": settings.BULLION_GOLDAPI_KEY.strip(),
                "Content-Type": "application/json",
            }
            if gold_10gm is None:
                req = Request("https://www.goldapi.io/api/XAU/INR", headers=headers)
                payload = json.loads(urlopen(req, timeout=8).read().decode("utf-8"))
                gold_pg = _to_float(payload.get("price_gram_24k") or payload.get("price_gram_9999") or payload.get("price_gram_999"))
                gold_10gm = gold_pg * 10 if gold_pg else gold_10gm
                if gold_10gm:
                    source = "GoldAPI"
                    updated = _format_api_timestamp(payload.get("timestamp"))
                    market_open = True
            if silver_1kg is None:
                req = Request("https://www.goldapi.io/api/XAG/INR", headers=headers)
                payload = json.loads(urlopen(req, timeout=8).read().decode("utf-8"))
                silver_pg = _to_float(payload.get("price_gram_999") or payload.get("price_gram_9999") or payload.get("price_gram_24k"))
                silver_1kg = silver_pg * 1000 if silver_pg else silver_1kg
                if silver_1kg:
                    source = "GoldAPI"
                    updated = updated or _format_api_timestamp(payload.get("timestamp"))
                    market_open = True
        except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError):
            pass

    api_url = getattr(settings, "BULLION_RATES_API_URL", "").strip()
    api_key = getattr(settings, "BULLION_RATES_API_KEY", "").strip()
    if (gold_10gm is None or silver_1kg is None) and api_url and api_key:
        try:
            params = urlencode({
                "api_key": api_key,
                "base": "INR",
                "currencies": "XAU,XAG",
            })
            sep = "&" if "?" in api_url else "?"
            request = Request(f"{api_url}{sep}{params}", headers={"User-Agent": "ShreeRudraBullion/1.0"})
            with urlopen(request, timeout=8) as response:
                payload = json.loads(response.read().decode("utf-8"))
            rates = payload.get("rates", {}) if isinstance(payload, dict) else {}
            xau_per_inr = _to_float(rates.get("XAU"))
            xag_per_inr = _to_float(rates.get("XAG"))
            gold_oz_inr = (1 / xau_per_inr) if xau_per_inr else _to_float(rates.get("INRXAU"))
            silver_oz_inr = (1 / xag_per_inr) if xag_per_inr else _to_float(rates.get("INRXAG"))
            if gold_10gm is None and gold_oz_inr:
                gold_10gm = gold_oz_inr / 31.1034768 * 10
            if silver_1kg is None and silver_oz_inr:
                silver_1kg = silver_oz_inr / 31.1034768 * 1000
            if gold_10gm or silver_1kg:
                source = source or "MetalpriceAPI"
                updated = updated or _format_api_timestamp(payload.get("timestamp"))
                market_open = True
        except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError, ZeroDivisionError):
            pass

    return {
        "gold_10gm": gold_10gm,
        "gold_10gm_bid": gold_buy,
        "gold_10gm_ask": gold_sell,
        "silver_1kg": silver_1kg,
        "silver_1kg_bid": silver_buy,
        "silver_1kg_ask": silver_sell,
        "gold_10gm_high": gold_high,
        "gold_10gm_low": gold_low,
        "silver_1kg_high": silver_high,
        "silver_1kg_low": silver_low,
        "usd_inr": usd_inr,
        "gold_usd": gold_usd,
        "silver_usd": silver_usd,
        "source": source or "Unavailable",
        "updated": updated,
        "market_open": market_open,
    }


def _to_float(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def _format_api_timestamp(value):
    if not value:
        return ""
    try:
        from datetime import datetime, timezone as dt_timezone
        return datetime.fromtimestamp(int(value), tz=dt_timezone.utc).strftime("%d %b %Y %I:%M %p UTC")
    except (TypeError, ValueError, OSError):
        return str(value)


def _apply_live_row_adjustment(value, operator, adjustment):
    if value is None:
        return None
    adjustment_value = _to_float(adjustment)
    if adjustment_value is None:
        adjustment_value = 0
    if operator == "-":
        return value - adjustment_value
    return value + adjustment_value


def get_bullion_rate_rows(site=None, market=None):
    market = market or _fetch_market_bullion_rates()
    rules = [
        ("gold_rtgs", "GOLD RTGS", "Gold", "10 GM", "gold_10gm"),
        ("silver_rtgs", "SILVER RTGS", "Silver", "1 KG", "silver_1kg"),
        ("silver_peti_rtgs", "SILVER PETI RTGS", "Silver", "1 KG", "silver_1kg"),
        ("gold_999", "GOLD 999", "Gold", "10 GM", "gold_10gm"),
        ("gold_9950", "GOLD 99.50", "Gold", "10 GM", "gold_10gm"),
        ("silver_peti_tukda", "SILVER PETI TUKDA", "Silver", "1 KG", "silver_1kg"),
        ("silver_chorsa_99", "SILVER CHORSA 99", "Silver", "1 KG", "silver_1kg"),
        ("silver_kacchi_50_90", "SILVER KACCHI (50-90T)", "Silver", "1 KG", "silver_1kg"),
    ]
    rows = []
    market_open = market.get("market_open")
    if market_open is None:
        market_open = any(
            market.get(key) is not None
            for key in (
                "gold_10gm_bid",
                "gold_10gm_ask",
                "silver_1kg_bid",
                "silver_1kg_ask",
                "gold_10gm",
                "silver_1kg",
            )
        )
    for key, label, metal, unit, base_key in rules:
        if site and not getattr(site, f"{key}_is_active", True):
            continue
        base_rate = market.get(base_key)
        buy = market.get(f"{base_key}_bid")
        sell = market.get(f"{base_key}_ask")
        if buy is None:
            buy = base_rate
        if sell is None:
            sell = base_rate
        if site and market_open:
            buy = _apply_live_row_adjustment(
                buy,
                getattr(site, f"{key}_buy_operator", "+"),
                getattr(site, f"{key}_buy_value", 0),
            )
            sell = _apply_live_row_adjustment(
                sell,
                getattr(site, f"{key}_sell_operator", "+"),
                getattr(site, f"{key}_sell_value", 0),
            )
        if not market_open:
            buy = None
            sell = None
        rows.append({
            "key": key,
            "label": label,
            "metal": metal,
            "unit": unit,
            "buy": _format_indian_rate(buy),
            "sell": _format_indian_rate(sell),
            "base": _format_indian_rate(base_rate),
            "high": _format_indian_rate(market.get(f"{base_key}_high")),
            "low": _format_indian_rate(market.get(f"{base_key}_low")),
            "formula": "",
        })
    return rows, market["source"], market["updated"]


def get_market_summary(market=None):
    market = market or _fetch_market_bullion_rates()
    return {
        "usd_inr": _format_decimal_rate(market.get("usd_inr"), 3),
        "gold_usd": _format_decimal_rate(market.get("gold_usd"), 2),
        "silver_usd": _format_decimal_rate(market.get("silver_usd"), 2),
    }


def get_market_base_rates(market=None):
    market = market or _fetch_market_bullion_rates()
    return {
        "gold_rtgs": _format_indian_rate(market.get("gold_10gm")),
        "silver_rtgs": _format_indian_rate(market.get("silver_1kg")),
    }


def get_our_rate_rows(live_rows, settings_obj=None):
    if not settings_obj:
        return []
    return [
        {
            **row,
            "formula": "",
        }
        for row in live_rows
    ]


def bullion_rates(request):
    if request.method == "POST":
        ContactEnquiry.objects.create(
            name=request.POST.get("name"),
            email=request.POST.get("email"),
            phone=request.POST.get("phone"),
            enquiry_type=request.POST.get("enquiry_type", "gold_bullion"),
            subject=request.POST.get("subject") or "Bullion Rate Enquiry",
            message=request.POST.get("message"),
        )
        params = urlencode({"submitted": "1"})
        return redirect(f"{request.path}?{params}")

    header = (
        PageHeader.objects.filter(page="bullion_rates", is_active=True).first()
        or PageHeader.objects.filter(page="live_rates", is_active=True).first()
        or PageHeader.objects.filter(page="shop", is_active=True).first()
    )
    site = WebsiteSettings.objects.first()
    our_settings, _ = OurRatesSettings.objects.get_or_create(id=1)
    market = _fetch_market_bullion_rates()
    rate_rows, rate_source, rate_updated = get_bullion_rate_rows(site, market)
    our_rate_rows = get_our_rate_rows(rate_rows, our_settings)
    market_summary = get_market_summary(market)
    market_base_rates = get_market_base_rates(market)
    response = render(request, "website/bullion_rates.html", {
        "rate_rows": rate_rows,
        "our_rate_rows": our_rate_rows,
        "market_summary": market_summary,
        "market_base_rates": market_base_rates,
        "rate_source": rate_source,
        "rate_updated": rate_updated,
        "rate_ticker_rows": our_rate_rows or rate_rows,
        "rate_ticker_source": rate_source,
        "rate_ticker_updated": rate_updated,
        "header": header,
    })
    response["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    return response


def bullion_rates_data(request):
    site = WebsiteSettings.objects.first()
    our_settings, _ = OurRatesSettings.objects.get_or_create(id=1)
    market = _fetch_market_bullion_rates()
    rate_rows, rate_source, rate_updated = get_bullion_rate_rows(site, market)
    our_rate_rows = get_our_rate_rows(rate_rows, our_settings)
    market_summary = get_market_summary(market)
    market_base_rates = get_market_base_rates(market)
    response = JsonResponse({
        "rate_rows": rate_rows,
        "our_rate_rows": our_rate_rows,
        "market_summary": market_summary,
        "market_base_rates": market_base_rates,
        "rate_source": rate_source,
        "rate_updated": rate_updated,
        "market_open": market.get("market_open", False),
    })
    response["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    return response


def faq_page(request):
    return render(request, "website/faq.html")


def privacy_policy(request):
    header = PageHeader.objects.filter(page="privacy_policy", is_active=True).first()
    return render(request, "website/privacy_policy.html", {"header": header})


def custom_404(request, exception):
    return render(request, "website/404.html", status=404)


def category_detail(request, slug):
    header = PageHeader.objects.filter(page="shop", is_active=True).first()
    category = get_object_or_404(ProductCategory, slug=slug, is_active=True)

    products_qs = Product.objects.filter(category=category, is_active=True)
    products_qs = _apply_product_filters(products_qs, request.GET).order_by("-created_at", "-id")

    paginator = Paginator(products_qs, 9)
    page_number = request.GET.get("page")
    page_obj = paginator.get_page(page_number)

    categories = ProductCategory.objects.filter(is_active=True).annotate(
        product_count=Count("products", filter=Q(products__is_active=True))
    )
    subcategories = ProductSubCategory.objects.filter(category=category, is_active=True)

    return render(request, "website/category.html", {
        "header": header,
        "products": page_obj,      # ✅ IMPORTANT
        "page_obj": page_obj,
        "categories": categories,
        "subcategories": subcategories,
        "active_category": category,
    })


from django.shortcuts import get_object_or_404
from .models import Product

def product_detail(request, slug):
    product = get_object_or_404(Product, slug=slug, is_active=True)

    return render(request, "website/product_detail.html", {
        "product": product
    })
