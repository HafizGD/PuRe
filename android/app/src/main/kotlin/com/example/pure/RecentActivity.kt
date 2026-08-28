package com.example.pure

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.RelativeLayout

class RecentActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_recent)

        setupBottomNavigation()

        // Setup click listeners for recent items
        val recentItem1 = findViewById<RelativeLayout>(R.id.newsImage1)?.parent as? RelativeLayout
        val recentItem2 = findViewById<RelativeLayout>(R.id.newsImage2)?.parent as? RelativeLayout
        val recentItem3 = findViewById<RelativeLayout>(R.id.newsImage3)?.parent as? RelativeLayout

        recentItem1?.setOnClickListener {
            val intent = Intent(this, MainNewsActivity::class.java)
            startActivity(intent)
        }

        recentItem2?.setOnClickListener {
            val intent = Intent(this, MainNewsActivity::class.java)
            startActivity(intent)
        }

        recentItem3?.setOnClickListener {
            val intent = Intent(this, MainNewsActivity::class.java)
            startActivity(intent)
        }

        // Setup bookmark icon toggle
        val bookmarkIcon1 = findViewById<ImageView>(R.id.bookmarkIcon1)
        val bookmarkIcon2 = findViewById<ImageView>(R.id.bookmarkIcon2)
        val bookmarkIcon3 = findViewById<ImageView>(R.id.bookmarkIcon3)

        var isBookmarked1 = false
        var isBookmarked2 = false
        var isBookmarked3 = false

        bookmarkIcon1?.setOnClickListener {
            isBookmarked1 = !isBookmarked1
            bookmarkIcon1.setImageResource(
                if (isBookmarked1) android.R.drawable.star_big_on
                else android.R.drawable.star_big_off
            )
        }

        bookmarkIcon2?.setOnClickListener {
            isBookmarked2 = !isBookmarked2
            bookmarkIcon2.setImageResource(
                if (isBookmarked2) android.R.drawable.star_big_on
                else android.R.drawable.star_big_off
            )
        }

        bookmarkIcon3?.setOnClickListener {
            isBookmarked3 = !isBookmarked3
            bookmarkIcon3.setImageResource(
                if (isBookmarked3) android.R.drawable.star_big_on
                else android.R.drawable.star_big_off
            )
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

