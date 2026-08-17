package com.brainclean.mobile

import android.content.Context
import android.content.Intent
import android.net.Uri

object ExternalLinkHelper {
    const val CHANNEL_NAME = "com.brainclean.mobile/external_links"

    fun openUri(context: Context, uriString: String): Boolean {
        return try {
            val uri = Uri.parse(uriString)
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }
}
