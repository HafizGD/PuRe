package com.example.pure

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.ImageButton
import android.widget.ImageView

class MainMenuActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_menu)

        setupBottomNavigation()

        // Setup news item click listeners
        val newsItem1 = findViewById<ImageView>(R.id.newsImage1)
        val newsItem2 = findViewById<ImageView>(R.id.newsImage2)

        newsItem1.setOnClickListener {
            val intent = Intent(this, MainNewsActivity::class.java)
            startActivity(intent)
        }

        newsItem2.setOnClickListener {
            val intent = Intent(this, MainNewsActivity::class.java)
            startActivity(intent)
        }
    }

    private fun setupBottomNavigation() {
        val backButton = findViewById<ImageButton>(R.id.backButton)
        val puzzleButton = findViewById<ImageButton>(R.id.puzzleButton)
        val menuButton = findViewById<ImageButton>(R.id.menuButton)

        backButton.setOnClickListener {
            finish()
        }

        puzzleButton.setOnClickListener {
            val intent = Intent(this, PuzzleActivity::class.java)
            startActivity(intent)
        }

        menuButton.setOnClickListener {
            val intent = Intent(this, BookshelfActivity::class.java)
            startActivity(intent)
        }
    }
}

