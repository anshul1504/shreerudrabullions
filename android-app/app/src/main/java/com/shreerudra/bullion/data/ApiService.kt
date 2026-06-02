package com.shreerudra.bullion.data

import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.Part
import retrofit2.http.Path
import retrofit2.http.Query
import okhttp3.MultipartBody

interface ApiService {
    @POST("auth/signup-request/")
    suspend fun signupRequest(@Body request: SignupRequest): SignupResponse

    @GET("auth/signup-status/")
    suspend fun signupStatus(@Query("mobile") mobile: String): SignupStatusResponse

    @POST("auth/login/")
    suspend fun login(@Body request: LoginRequest): LoginResponse

    @POST("auth/forgot-password/")
    suspend fun forgotPassword(@Body request: ForgotPasswordRequest): MessageResponse

    @GET("profile/")
    suspend fun profile(@Header("Authorization") authorization: String): AppUser

    @Multipart
    @POST("profile/")
    suspend fun uploadProfileImage(
        @Header("Authorization") authorization: String,
        @Part profile_image: MultipartBody.Part,
    ): MessageResponse

    @POST("profile/update-request/")
    suspend fun profileUpdateRequest(
        @Header("Authorization") authorization: String,
        @Body request: ProfileUpdateRequest,
    ): MessageResponse

    @GET("home/")
    suspend fun home(@Header("Authorization") authorization: String): HomeInfo

    @GET("about/")
    suspend fun about(@Header("Authorization") authorization: String): AboutInfo

    @GET("live-rates/")
    suspend fun liveRates(@Header("Authorization") authorization: String): LiveRatesResponse

    @GET("products/")
    suspend fun products(@Header("Authorization") authorization: String): ProductsResponse

    @GET("products/{slug}/")
    suspend fun productDetail(
        @Header("Authorization") authorization: String,
        @Path("slug") slug: String,
    ): ProductDetail

    @GET("contact/")
    suspend fun contact(@Header("Authorization") authorization: String): ContactInfo

    @POST("contact/")
    suspend fun submitContact(
        @Header("Authorization") authorization: String,
        @Body request: ContactRequest,
    ): MessageResponse

    @GET("privacy-policy/")
    suspend fun privacyPolicy(): PrivacyPolicy
}
