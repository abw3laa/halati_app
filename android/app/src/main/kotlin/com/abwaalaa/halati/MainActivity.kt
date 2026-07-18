package com.abwaalaa.halati

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

/**
 * Bridges a single call — `saveToPublicStorage` — used by
 * [lib/services/media_store_service.dart] so downloaded/saved files show
 * up in the phone's own Gallery app (videos/images) and in a normal file
 * manager's Download folder (everything else), instead of sitting only
 * inside the app's private, invisible external-files directory.
 *
 * MediaStore is the only supported way to write into those public
 * collections on Android 10+ (scoped storage) without requesting the
 * broad, Play-Store-restricted MANAGE_EXTERNAL_STORAGE permission.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.abwaalaa.halati/media_store"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToPublicStorage" -> {
                        try {
                            val sourcePath = call.argument<String>("sourcePath")!!
                            val displayName = call.argument<String>("displayName")!!
                            val mimeType = call.argument<String>("mimeType")!!
                            val collection = call.argument<String>("collection")!! // "video" | "image" | "downloads"
                            val publicUri = saveToPublicStorage(sourcePath, displayName, mimeType, collection)
                            result.success(publicUri)
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveToPublicStorage(
        sourcePath: String,
        displayName: String,
        mimeType: String,
        collection: String,
    ): String {
        val resolver = applicationContext.contentResolver

        val (collectionUri, relativeDir) = when (collection) {
            "video" -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI to "Movies/Halati"
            "image" -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI to "Pictures/Halati"
            else -> {
                // Generic downloads (audio, etc.) — MediaStore.Downloads only
                // exists from API 29 onward; fall back to a direct public-dir
                // write on older devices via the legacy external storage path.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    MediaStore.Downloads.EXTERNAL_CONTENT_URI to "Download/Halati"
                } else {
                    val legacyDir = File(
                        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                        "Halati",
                    )
                    if (!legacyDir.exists()) legacyDir.mkdirs()
                    val dest = File(legacyDir, displayName)
                    FileInputStream(sourcePath).use { input ->
                        FileOutputStream(dest).use { output -> input.copyTo(output) }
                    }
                    return dest.absolutePath
                }
            }
        }

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, displayName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, relativeDir)
        }

        val itemUri = resolver.insert(collectionUri, values)
            ?: throw IllegalStateException("MediaStore insert returned null")

        resolver.openOutputStream(itemUri)?.use { output ->
            FileInputStream(sourcePath).use { input -> input.copyTo(output) }
        } ?: throw IllegalStateException("Could not open output stream for $itemUri")

        return itemUri.toString()
    }
}
