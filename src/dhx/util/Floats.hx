package dhx.util;

class Floats
{
	public static function interpolatef(a = 0.0, b = 1.0, ?equation : Float -> Float)
	{
		if (null == equation)
			equation = function(f) return f;
		var d = b - a;
		return function(f) return a + equation(f) * d;
	}
}