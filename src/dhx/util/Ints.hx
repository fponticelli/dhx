package dhx.util;

class Ints
{
	public static function interpolatef(min = 0.0, max = 1.0, ?equation : Float -> Float)
	{
		if (null == equation)
			equation = function(f) return f;
		var d = max - min;
		return function(f) return Math.round(min + equation(f) * d);
	}
}