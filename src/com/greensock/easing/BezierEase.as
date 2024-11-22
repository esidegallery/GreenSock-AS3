package com.greensock.easing
{
	import com.greensock.easing.Ease;

	/** A cubic bezier easing class for GSAP. */
	public class BezierEase extends Ease
	{
		private static const NEWTON_ITERATIONS:int = 4;
		private static const NEWTON_MIN_SLOPE:Number = 0.001;
		private static const SUBDIVISION_PRECISION:Number = 0.0000001;
		private static const SUBDIVISION_MAX_ITERATIONS:int = 10;
		private static const SPLINE_TABLE_SIZE:int = 11;
		private static const SAMPLE_STEP_SIZE:Number = 1.0 / (SPLINE_TABLE_SIZE - 1.0);

		private var func:Function;

		public function BezierEase(x1:Number, y1:Number, x2:Number, y2:Number)
		{
			if (x1 < 0 || x1 > 1 || x2 < 0 || x2 > 1)
			{
				throw new ArgumentError("x values must be in range [0, 1]");
			}

			if (x1 == y1 && x2 == y2)
			{
				func = linearEasing;
				return;
			}

			var sampleValues:Array = []; // pre-computed samples table

			for (var i:int = 0; i < SPLINE_TABLE_SIZE; ++i)
			{
				sampleValues[i] = calcBezier(i * SAMPLE_STEP_SIZE, x1, x2);
			}

			func = _bezierEasing;

			function _getTForX(x:Number):Number
			{
				var intervalStart:Number = 0.0;
				var currentSample:int = 1;
				var lastSample:int = SPLINE_TABLE_SIZE - 1;

				for (; currentSample != lastSample && sampleValues[currentSample] <= x; ++currentSample)
				{
					intervalStart += SAMPLE_STEP_SIZE;
				}

				-- currentSample;

				// Interpolate to provide an initial guess for t:
				var dist:Number = (x - sampleValues[currentSample]) / (sampleValues[currentSample + 1] - sampleValues[currentSample]);
				var guessForT:Number = intervalStart + dist * SAMPLE_STEP_SIZE;

				var initialSlope:Number = getSlope(guessForT, x1, x2);
				if (initialSlope >= NEWTON_MIN_SLOPE)
				{
					return newtonRaphsonIterate(x, guessForT, x1, x2);
				}
				if (initialSlope === 0.0)
				{
					return guessForT;
				}
				return binarySubdivide(x, intervalStart, intervalStart + SAMPLE_STEP_SIZE, x1, x2);
			}

			function _bezierEasing(ratio:Number):Number
			{
				if (ratio == 0)
				{
					return 0;
				}
				if (ratio == 1)
				{
					return 1;
				}
				return calcBezier(_getTForX(ratio), y1, y2);
			}
		}

		override public function getRatio(p:Number):Number
		{
			return func(p);
		}

		private static function calcBezier(t:Number, a1:Number, a2:Number):Number
		{
			return (((1 - 3 * a2 + 3 * a1) * t + (3 * a2 - 6 * a1)) * t + (3 * a1)) * t;
		}

		private static function getSlope(t:Number, a1:Number, a2:Number):Number
		{
			return 3 * (1 - 3 * a2 + 3 * a1) * t * t + 2 * (3 * a2 - 6 * a1) * t + (3 * a1);
		}

		private static function binarySubdivide(ratio:Number, a:Number, b:Number, x1:Number, x2:Number):Number
		{
			var currentX:Number, t:Number, i:uint = 0;

			do
			{
				t = a + (b - a) / 2;
				currentX = calcBezier(t, x1, x2) - ratio;
				if (currentX > 0)
				{
					b = t;
				}
				else
				{
					a = t;
				}
			}
			while (Math.abs(currentX) > SUBDIVISION_PRECISION && ++i < SUBDIVISION_MAX_ITERATIONS);

			return t;
		}

		private static function newtonRaphsonIterate(x:Number, t:Number, x1:Number, x2:Number):Number
		{
			for (var i:int = 0; i < NEWTON_ITERATIONS; ++i)
			{
				var currentSlope:Number = getSlope(t, x1, x2);
				if (currentSlope == 0.0)
				{
					return t;
				}
				var currentX:Number = calcBezier(t, x1, x2) - x;
				t -= currentX / currentSlope;
			}
			return t;
		}

		private static function linearEasing(ratio:Number):Number
		{
			return ratio;
		}
	}
}