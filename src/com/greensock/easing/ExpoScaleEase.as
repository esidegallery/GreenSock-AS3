package com.greensock.easing
{
	/**
	 * There's an interesting phenomena that occurs when you animate an object's scale that makes it appear to change 
	 * speed even with a linear ease; ExpoScaleEase compensates for this effect by bending the easing curve accordingly. 
	 * This is the secret sauce for silky-smooth zooming/scaling animations.
	 */
	public class ExpoScaleEase extends Ease
	{
		protected var _ease:Ease;
		
		public function ExpoScaleEase(startingScale:Number, endingScale:Number, ease:Ease = null) {
			_p1 = Math.log(endingScale / startingScale);
			_p2 = endingScale - startingScale;
			_p3 = startingScale;
			_ease = ease;
		}
		
		/**
		 * Converts a linear progress value between 0 and 1 (where 0 is the start, 0.5 is halfway through, and 1 is completion) 
		 * into the corresponding eased value (typically also between 0 and 1, 
		 * although some eases like Elastic and Back shoot past those values and then return)
		 */
		override public function getRatio(p:Number):Number {
			if (_ease) {
				p = _ease.getRatio(p);
			}
			if (_p2)
			{
				return (_p3 * Math.exp(_p1 * p) - _p3) / _p2;
			}
			return p;
		}
		
		/**
		 * @return An ease that's built specifically for the starting and ending values you define. 
		 * By default, it uses a Linear.easeNone ease, but you can optionally define a different one in the 3rd parameter, 
		 * like Power2.easeInOut.
		 */
		public function config(startingScale:Number, endingScale:Number, ease:Ease = null):ExpoScaleEase {
			return new ExpoScaleEase(startingScale, endingScale, ease);
		}
	}
}