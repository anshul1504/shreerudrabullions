package com.shreerudra.bullion.data

data class SignupRequest(
    val name: String,
    val mobile: String,
    val password: String,
    val confirm_password: String,
    val message: String = "",
    val fcm_token: String = "",
)

data class SignupResponse(
    val id: Int,
    val status: String,
    val message: String,
)

data class SignupStatusResponse(
    val mobile: String,
    val status: String,
    val message: String,
)

data class LoginRequest(
    val mobile: String,
    val password: String,
)

data class LoginResponse(
    val access: String,
    val refresh: String,
    val user: AppUser,
)

data class ForgotPasswordRequest(
    val mobile: String,
    val password: String,
    val confirm_password: String,
)

data class MessageResponse(
    val message: String,
)

data class ContactRequest(
    val name: String,
    val email: String,
    val phone: String,
    val enquiry_type: String = "gold_bullion",
    val subject: String = "App enquiry",
    val message: String,
)

data class ProfileUpdateRequest(
    val name: String,
    val mobile: String,
    val city: String = "",
    val message: String = "",
)

data class AppUser(
    val id: Int,
    val name: String,
    val mobile: String,
    val profile_image: String = "",
)

data class LiveRatesResponse(
    val market_open: Boolean,
    val rate_source: String,
    val rate_updated: String,
    val market_summary: MarketSummary,
    val market_base_rates: MarketBaseRates,
    val rows: List<RateRow>,
)

data class MarketSummary(
    val usd_inr: String = "",
    val gold_usd: String = "",
    val silver_usd: String = "",
)

data class MarketBaseRates(
    val gold_rtgs: String = "",
    val silver_rtgs: String = "",
)

data class RateRow(
    val key: String,
    val label: String,
    val unit: String,
    val buy: String,
    val sell: String,
)

data class ProductsResponse(
    val products: List<ProductItem>,
)

data class ProductItem(
    val id: Int,
    val title: String,
    val slug: String,
    val category: String,
    val subcategory: String = "",
    val metal_type: String,
    val purity: String,
    val price: String,
    val old_price: String,
    val weight: String = "",
    val is_in_stock: Boolean,
    val image: String,
)

data class ProductDetail(
    val id: Int,
    val title: String,
    val slug: String,
    val category: String,
    val subcategory: String = "",
    val metal_type: String,
    val purity: String,
    val price: String,
    val old_price: String,
    val weight: String,
    val making_charges: String,
    val hallmark: String,
    val description: String,
    val shipping_details: String,
    val is_in_stock: Boolean,
    val images: List<String>,
)

data class ContactInfo(
    val phone: String,
    val email: String,
    val address: String,
    val footer_phone_numbers: List<String>,
)

data class HomeInfo(
    val site_name: String,
    val tagline: String = "",
    val logo: String = "",
    val phone: String = "",
    val address: String = "",
    val footer_text: String = "",
    val weekday_label: String = "",
    val weekday_time: String = "",
    val sunday_label: String = "",
    val sunday_time: String = "",
    val sliders: List<HomeSliderItem> = emptyList(),
    val categories: List<HomeCategoryItem> = emptyList(),
    val products: List<HomeProductItem> = emptyList(),
    val testimonials: List<AboutTestimonial> = emptyList(),
)

data class HomeSliderItem(
    val title: String = "",
    val image: String = "",
    val link: String = "",
)

data class HomeCategoryItem(
    val id: Int = 0,
    val title: String = "",
    val subtitle: String = "",
    val slug: String = "",
    val image: String = "",
)

data class HomeProductItem(
    val id: Int = 0,
    val title: String = "",
    val slug: String = "",
    val category: String = "",
    val price: String = "",
    val old_price: String = "",
    val image: String = "",
)

data class AboutInfo(
    val header_title: String = "",
    val header_subtitle: String = "",
    val header_background: String = "",
    val vision_title: String = "",
    val vision_text: String = "",
    val mission_title: String = "",
    val mission_text: String = "",
    val who_title: String = "",
    val who_subtitle: String = "",
    val who_description: String = "",
    val who_button_text: String = "",
    val who_button_url: String = "",
    val who_image: String = "",
    val brands: List<AboutBrand> = emptyList(),
    val testimonials: List<AboutTestimonial> = emptyList(),
)

data class AboutBrand(
    val name: String = "",
    val logo: String = "",
)

data class AboutTestimonial(
    val name: String = "",
    val role: String = "",
    val message: String = "",
    val photo: String = "",
)

data class PrivacyPolicy(
    val title: String,
    val effective_date: String,
    val content: String,
)
