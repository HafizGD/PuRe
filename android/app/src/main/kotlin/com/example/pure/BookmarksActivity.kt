package com.example.pure

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.RelativeLayout

class BookmarksActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bookmarks)

        setupBottomNavigation()

        // Setup click listeners for bookmark items
        val bookmarkItem1 = findViewById<RelativeLayout>(R.id.newsImage1)?.parent as? RelativeLayout
        val bookmarkItem2 = findViewById<RelativeLayout>(R.id.newsImage2)?.parent as? RelativeLayout
        val bookmarkItem3 = findViewById<RelativeLayout>(R.id.newsImage3)?.parent as? RelativeLayout

        bookmarkItem1?.setOnClickListener {
            val intent = Intent(this, MainNewsActivity::class.java)
            startActivity(intent)
        }

        bookmarkItem2?.setOnClickListener {
            val intent = Intent(this, MainNewsActivity::class.java)
            startActivity(intent)
        }

        bookmarkItem3?.setOnClickListener {
            val intent = Intent(this, MainNewsActivity::class.java)
            startActivity(intent)
        }

        // Setup bookmark icon toggle
        val bookmarkIcon1 = findViewById<ImageView>(R.id.bookmarkIcon1)
        val bookmarkIcon2 = findViewById<ImageView>(R.id.bookmarkIcon2)
        val bookmarkIcon3 = findViewById<ImageView>(R.id.bookmarkIcon3)

        bookmarkIcon1?.setOnClickListener {
            // Remove from bookmarks
            finish()
        }

        bookmarkIcon2?.setOnClickListener {
            // Remove from bookmarks
            finish()
        }

        bookmarkIcon3?.setOnClickListener {
            // Remove from bookmarks
            finish()
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

