package com.shreerudra.bullion.data

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import java.util.concurrent.TimeUnit

class ApprovalStatusWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        SessionStore.init(applicationContext)
        AppNotifier.init(applicationContext)
        val mobile = SessionStore.pendingSignupMobile
        if (mobile.isBlank()) return Result.success()

        return runCatching {
            val status = ApiClient.service.signupStatus(mobile)
            if (status.status == "approved") {
                AppNotifier.showApproved()
                SessionStore.setPendingSignup("")
            }
            Result.success()
        }.getOrElse {
            Result.retry()
        }
    }

    companion object {
        private const val ONE_TIME_WORK = "approval_status_check_once"
        private const val PERIODIC_WORK = "approval_status_check_periodic"

        fun schedule(context: Context) {
            val manager = WorkManager.getInstance(context)
            manager.enqueueUniqueWork(
                ONE_TIME_WORK,
                ExistingWorkPolicy.REPLACE,
                OneTimeWorkRequestBuilder<ApprovalStatusWorker>().build(),
            )
            manager.enqueueUniquePeriodicWork(
                PERIODIC_WORK,
                ExistingPeriodicWorkPolicy.UPDATE,
                PeriodicWorkRequestBuilder<ApprovalStatusWorker>(15, TimeUnit.MINUTES).build(),
            )
        }
    }
}
