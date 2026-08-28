package com.example.pure

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Navigate to HomepageActivity when Flutter activity starts
        // Uncomment the line below if you want to start with native Android activities
        // startActivity(Intent(this, HomepageActivity::class.java))
    }
}
