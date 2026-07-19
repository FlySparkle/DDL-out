package com.flysparkle.ddlout

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ddl_out/app_update",
        ).setMethodCallHandler { call, result ->
            if (call.method == "ensureInstallPermission") {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
                    packageManager.canRequestPackageInstalls()
                ) {
                    result.success(true)
                } else {
                    startActivity(
                        Intent(
                            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                            Uri.parse("package:$packageName"),
                        ),
                    )
                    result.success(false)
                }
                return@setMethodCallHandler
            }
            if (call.method != "installApk") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val apkPath = call.argument<String>("path")
            if (apkPath == null) {
                result.error("invalid_path", "The APK path is missing.", null)
                return@setMethodCallHandler
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                !packageManager.canRequestPackageInstalls()
            ) {
                startActivity(
                    Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.parse("package:$packageName"),
                    ),
                )
                result.success("permission_required")
                return@setMethodCallHandler
            }
            val apk = File(apkPath)
            if (!apk.isFile) {
                result.error("missing_apk", "The downloaded APK is missing.", null)
                return@setMethodCallHandler
            }
            val contentUri = FileProvider.getUriForFile(
                this,
                "$packageName.update_provider",
                apk,
            )
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(contentUri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(intent)
            result.success("installer_opened")
        }
    }
}
