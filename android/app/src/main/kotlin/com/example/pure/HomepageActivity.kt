package com.example.pure

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.Button

class HomepageActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_homepage)

        val button1 = findViewById<Button>(R.id.button1)
        val button2 = findViewById<Button>(R.id.button2)

        button1.setOnClickListener {
            // Navigate to main menu or other activity
            val intent = Intent(this, MainMenuActivity::class.java)
            startActivity(intent)
        }

        button2.setOnClickListener {
            // Navigate to main menu or other activity
            val intent = Intent(this, MainMenuActivity::class.java)
            startActivity(intent)
        }
    }
}

