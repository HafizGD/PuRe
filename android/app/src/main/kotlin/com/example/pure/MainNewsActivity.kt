package com.example.pure

import android.content.Intent
import android.os.Bundle
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.bumptech.glide.Glide

class MainNewsActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_news)

        setupBottomNavigation()

        // Get data from Intent
        val title = intent.getStringExtra("title") ?: "Judul Tidak Tersedia"
        val description = intent.getStringExtra("description") ?: "Deskripsi tidak tersedia."
        val imageUrl = intent.getStringExtra("imageUrl") ?: ""

        // Set title
        val newsTitle = findViewById<TextView>(R.id.newsTitle)
        newsTitle.text = title

        // Set description
        val newsContent1 = findViewById<TextView>(R.id.newsContent1)
        val newsContent2 = findViewById<TextView>(R.id.newsContent2)
        
        if (description.isNotEmpty()) {
            val words = description.split(" ")
            val midPoint = words.size / 2
            val firstHalf = words.take(midPoint).joinToString(" ")
            val secondHalf = words.drop(midPoint).joinToString(" ")
            
            newsContent1.text = firstHalf
            newsContent2.text = secondHalf
        } else {
            newsContent1.text = "Tidak ada deskripsi berita."
            newsContent2.text = ""
        }

        // Load image
        if (imageUrl.isNotEmpty()) {
            val mainNewsImage = findViewById<ImageView>(R.id.mainNewsImage)
            Glide.with(this)
                .load(imageUrl)
                .centerCrop()
                .into(mainNewsImage)
        }

        // Bookmark functionality
        val bookmarkIcon = findViewById<ImageView>(R.id.bookmarkIcon)
        var isBookmarked = false

        bookmarkIcon.setOnClickListener {
            isBookmarked = !isBookmarked
            bookmarkIcon.setImageResource(
                if (isBookmarked) android.R.drawable.star_big_on
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

