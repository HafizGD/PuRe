package com.example.pure

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.ImageButton
import android.widget.RelativeLayout

class BookshelfActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bookshelf)

        setupBottomNavigation()

        // Setup click listeners for bookmarks and recent sections
        val bookmarksSection = findViewById<RelativeLayout>(R.id.bookmarksSection)
        val recentSection = findViewById<RelativeLayout>(R.id.recentSection)

        bookmarksSection?.setOnClickListener {
            val intent = Intent(this, BookmarksActivity::class.java)
            startActivity(intent)
        }

        recentSection?.setOnClickListener {
            val intent = Intent(this, RecentActivity::class.java)
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
            // Already on menu page
        }
    }
}

