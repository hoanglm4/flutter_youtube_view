package com.hoanglm.flutteryoutubeview

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.widget.FrameLayout

class FLTPlayerView : FrameLayout {
    private var mode: VideoScaleMode? = null

    constructor(context: Context) : this(context, null)
    constructor(context: Context, attrs: AttributeSet?) : this(context, attrs, 0)
    constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) : super(
        context,
        attrs,
        defStyleAttr
    )

    fun setVideoScaleMode(mode: VideoScaleMode) {
        this.mode = mode
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val size = measureSize(widthMeasureSpec, heightMeasureSpec)
        super.onMeasure(size.first, size.second)
    }

    private fun measureSize(widthMeasureSpec: Int, heightMeasureSpec: Int): Pair<Int, Int> {
        when (mode) {
            VideoScaleMode.NONE -> {
                return Pair(widthMeasureSpec, heightMeasureSpec)
            }
            VideoScaleMode.FIT_WIDTH -> {
                val sixteenNineHeight = View.MeasureSpec.makeMeasureSpec(
                    (View.MeasureSpec.getSize(widthMeasureSpec) / Constans.VIDEO_RATIO).toInt(),
                    View.MeasureSpec.EXACTLY
                )
                return Pair(widthMeasureSpec, sixteenNineHeight)
            }
            VideoScaleMode.FIT_HEIGHT -> {
                val sixteenNineWidth = View.MeasureSpec.makeMeasureSpec(
                    (View.MeasureSpec.getSize(heightMeasureSpec) * Constans.VIDEO_RATIO).toInt(),
                    View.MeasureSpec.EXACTLY
                )
                return Pair(sixteenNineWidth, heightMeasureSpec)
            }
            else -> return Pair(widthMeasureSpec, heightMeasureSpec)
        }
    }
}