package com.example.pure

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.transition.Transition
import okhttp3.*
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.util.*
import kotlin.collections.ArrayList

class PuzzleActivity : AppCompatActivity() {

    private lateinit var tvNamaArt: TextView
    private lateinit var puzzleGrid: GridLayout
    private var imageUrlGlobal: String = ""
    private var descriptionGlobal: String = ""
    private lateinit var buttonSkip: Button
    private lateinit var resetButton: com.google.android.material.floatingactionbutton.FloatingActionButton

    // Puzzle variables
    private val puzzlePieces = ArrayList<FrameLayout?>()
    private val correctOrder = ArrayList<Int>()
    private val puzzleState = ArrayList<Int>()
    private val rows = 3
    private val cols = 3

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_puzzle)

        tvNamaArt = findViewById(R.id.namaArt)
        puzzleGrid = findViewById(R.id.puzzleGrid)
        buttonSkip = findViewById(R.id.buttonSkip)
        resetButton = findViewById(R.id.resetButton)

        setupBottomNavigation()
        fetchNewsImage()

        buttonSkip.setOnClickListener {
            if (imageUrlGlobal.isNotEmpty()) {
                val intent = Intent(this, MainNewsActivity::class.java)
                intent.putExtra("title", tvNamaArt.text.toString())
                intent.putExtra("description", descriptionGlobal)
                intent.putExtra("imageUrl", imageUrlGlobal)
                startActivity(intent)
            }
        }

        resetButton.setOnClickListener {
            Glide.get(applicationContext).clearMemory()
            Thread {
                Glide.get(applicationContext).clearDiskCache()
            }.start()
            fetchNewsImage()
        }
    }

    private fun fetchNewsImage() {
        val client = OkHttpClient()

        val requestUrl = "https://api.worldnewsapi.com/search-news?source-countries=id&number=50"

        val request = Request.Builder()
            .url(requestUrl)
            .addHeader("x-api-key", "c4ff530182a9417b92cc930fcab1adf0")
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                runOnUiThread {
                    Toast.makeText(this@PuzzleActivity, "Gagal ambil berita", Toast.LENGTH_SHORT).show()
                }
            }

            override fun onResponse(call: Call, response: Response) {
                if (!response.isSuccessful) {
                    runOnUiThread {
                        Toast.makeText(this@PuzzleActivity, "Response gagal: ${response.code}", Toast.LENGTH_SHORT).show()
                    }
                    return
                }

                val body = response.body?.string()
                if (body == null) {
                    runOnUiThread {
                        Toast.makeText(this@PuzzleActivity, "Response body kosong", Toast.LENGTH_SHORT).show()
                    }
                    return
                }

                Log.d("NEWS_API", body)

                try {
                    val obj = JSONObject(body)
                    val newsArray = obj.getJSONArray("news")

                    if (newsArray.length() > 0) {
                        var randomArticle: JSONObject? = null
                        var imageUrl = ""
                        val maxTries = 10
                        var tries = 0

                        while ((imageUrl.isEmpty() || imageUrl == "null") && tries < maxTries && tries < newsArray.length()) {
                            val randomIndex = Random().nextInt(newsArray.length())
                            randomArticle = newsArray.getJSONObject(randomIndex)
                            imageUrl = randomArticle.optString("image", "")
                            tries++
                        }

                        if (randomArticle != null && imageUrl.isNotEmpty() && imageUrl != "null") {
                            imageUrlGlobal = imageUrl
                            descriptionGlobal = randomArticle.optString("text", "Deskripsi tidak tersedia.")
                            val title = randomArticle.optString("title", "Judul Tidak Tersedia")

                            runOnUiThread {
                                tvNamaArt.text = title
                            }

                            Glide.with(this@PuzzleActivity)
                                .asBitmap()
                                .load(imageUrlGlobal)
                                .into(object : CustomTarget<Bitmap>() {
                                    override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                                        val squareBitmap = cropToSquare(resource)
                                        createPuzzle(squareBitmap)
                                    }

                                    override fun onLoadCleared(placeholder: Drawable?) {}
                                })
                        } else {
                            runOnUiThread {
                                Toast.makeText(this@PuzzleActivity, "Gagal menemukan berita dengan gambar", Toast.LENGTH_SHORT).show()
                            }
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    runOnUiThread {
                        Toast.makeText(this@PuzzleActivity, "Error parsing JSON", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        })
    }

    private fun cropToSquare(src: Bitmap): Bitmap {
        val width = src.width
        val height = src.height
        val newSize = minOf(width, height)

        val xOffset = (width - newSize) / 2
        val yOffset = (height - newSize) / 2

        return Bitmap.createBitmap(src, xOffset, yOffset, newSize, newSize)
    }

    private fun createPuzzle(bitmap: Bitmap) {
        val pieceWidth = bitmap.width / cols
        val pieceHeight = bitmap.height / rows

        runOnUiThread {
            puzzleGrid.removeAllViews()
            puzzlePieces.clear()
            puzzleState.clear()
            correctOrder.clear()

            for (row in 0 until rows) {
                for (col in 0 until cols) {
                    val index = row * cols + col

                    if (index < rows * cols - 1) {
                        val piece = Bitmap.createBitmap(
                            bitmap,
                            col * pieceWidth,
                            row * pieceHeight,
                            pieceWidth,
                            pieceHeight
                        )

                        val frame = FrameLayout(this@PuzzleActivity)

                        val imageView = ImageView(this@PuzzleActivity)
                        imageView.setImageBitmap(piece)
                        imageView.scaleType = ImageView.ScaleType.CENTER_CROP
                        val imgParams = FrameLayout.LayoutParams(
                            FrameLayout.LayoutParams.MATCH_PARENT,
                            FrameLayout.LayoutParams.MATCH_PARENT
                        )
                        imageView.layoutParams = imgParams

                        val numberHint = TextView(this@PuzzleActivity)
                        numberHint.text = (index + 1).toString()
                        numberHint.textSize = 14f
                        numberHint.setTextColor(Color.WHITE)
                        numberHint.setBackgroundColor(Color.parseColor("#66000000"))
                        numberHint.setPadding(6, 2, 6, 2)

                        val numParams = FrameLayout.LayoutParams(
                            FrameLayout.LayoutParams.WRAP_CONTENT,
                            FrameLayout.LayoutParams.WRAP_CONTENT
                        )
                        numParams.gravity = Gravity.TOP or Gravity.START
                        numberHint.layoutParams = numParams

                        frame.addView(imageView)
                        frame.addView(numberHint)

                        puzzlePieces.add(frame)
                        correctOrder.add(index + 1)
                        puzzleState.add(index + 1)
                    } else {
                        puzzlePieces.add(null)
                        correctOrder.add(0)
                        puzzleState.add(0)
                    }
                }
            }

            puzzleState.clear()
            puzzleState.addAll(generateSolvablePuzzleState())
            drawPuzzle()
        }
    }

    private fun drawPuzzle() {
        puzzleGrid.removeAllViews()

        val gridSize = minOf(puzzleGrid.width, puzzleGrid.height)
        if (gridSize == 0) {
            puzzleGrid.post { drawPuzzle() }
            return
        }
        val cellSize = gridSize / cols

        for (i in puzzleState.indices) {
            val value = puzzleState[i]

            val params = GridLayout.LayoutParams().apply {
                width = cellSize
                height = cellSize
                rowSpec = GridLayout.spec(i / cols)
                columnSpec = GridLayout.spec(i % cols)
            }

            if (value != 0) {
                val piece = puzzlePieces[value - 1]
                if (piece != null) {
                    if (piece.parent != null) {
                        (piece.parent as? GridLayout)?.removeView(piece)
                    }
                    piece.layoutParams = params
                    puzzleGrid.addView(piece)

                    val index = i
                    piece.setOnClickListener { movePiece(index) }
                }
            } else {
                val emptyView = TextView(this)
                emptyView.layoutParams = params
                puzzleGrid.addView(emptyView)
            }
        }
    }

    private fun generateSolvablePuzzleState(): List<Int> {
        val state = ArrayList<Int>()
        val total = rows * cols
        for (i in 1 until total) {
            state.add(i)
        }
        state.add(0)

        val random = Random()
        var emptyIndex = state.indexOf(0)

        val shuffleMoves = maxOf(100, total * 50)
        var lastEmptyIndex = -1
        for (m in 0 until shuffleMoves) {
            val neighbors = getAdjacentIndices(emptyIndex)
            if (neighbors.size > 1 && lastEmptyIndex != -1) {
                neighbors.removeAll { it == lastEmptyIndex }
            }
            val targetIndex = neighbors[random.nextInt(neighbors.size)]
            Collections.swap(state, emptyIndex, targetIndex)
            lastEmptyIndex = emptyIndex
            emptyIndex = targetIndex
        }

        if (isSolved(state)) {
            val neighbors = getAdjacentIndices(emptyIndex)
            val targetIndex = neighbors[random.nextInt(neighbors.size)]
            Collections.swap(state, emptyIndex, targetIndex)
        }

        return state
    }

    private fun isSolved(state: List<Int>): Boolean {
        if (state.size != rows * cols) return false
        for (i in 0 until state.size - 1) {
            if (state[i] != i + 1) return false
        }
        return state[state.size - 1] == 0
    }

    private fun getAdjacentIndices(index: Int): MutableList<Int> {
        val result = ArrayList<Int>()
        val r = index / cols
        val c = index % cols
        if (r > 0) result.add((r - 1) * cols + c)
        if (r < rows - 1) result.add((r + 1) * cols + c)
        if (c > 0) result.add(r * cols + (c - 1))
        if (c < cols - 1) result.add(r * cols + (c + 1))
        return result
    }

    private fun movePiece(index: Int) {
        val emptyIndex = puzzleState.indexOf(0)

        if (isAdjacent(index, emptyIndex)) {
            Collections.swap(puzzleState, index, emptyIndex)
            drawPuzzle()

            if (puzzleState == correctOrder) {
                val intent = Intent(this, MainNewsActivity::class.java)
                intent.putExtra("title", tvNamaArt.text.toString())
                intent.putExtra("description", descriptionGlobal)
                intent.putExtra("imageUrl", imageUrlGlobal)
                startActivity(intent)
            }
        }
    }

    private fun isAdjacent(i: Int, j: Int): Boolean {
        val rowI = i / cols
        val colI = i % cols
        val rowJ = j / cols
        val colJ = j % cols
        return (Math.abs(rowI - rowJ) + Math.abs(colI - colJ)) == 1
    }

    private fun setupBottomNavigation() {
        val backButton = findViewById<ImageButton>(R.id.backButton)
        val puzzleButton = findViewById<ImageButton>(R.id.puzzleButton)
        val menuButton = findViewById<ImageButton>(R.id.menuButton)

        backButton.setOnClickListener {
            finish()
        }

        puzzleButton.setOnClickListener {
            // Already on puzzle page
        }

        menuButton.setOnClickListener {
            val intent = Intent(this, BookshelfActivity::class.java)
            startActivity(intent)
        }
    }
}
