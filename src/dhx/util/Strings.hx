package dhx.util;

class Strings
{
	static var _reInterpolateNumber = ~/[-+]?(?:\d+\.\d+|\d+\.|\.\d+|\d+)(?:[eE][-]?\d+)?/;
	public static function interpolate(v : Float, a : String, b : String, ?equation : Float -> Float)
	{
		return interpolatef(a, b, equation)(v);
	}

	public static function interpolatef(a : String, b : String, ?equation : Float -> Float)
	{
		function extract(value : String, s : Array<String>, f : Array<Null<Float>>)
		{
			while (_reInterpolateNumber.match(value))
			{
				var left = _reInterpolateNumber.matchedLeft();
				if (!Strings.empty(left))
				{
					s.push(left);
					f.push(null);
				}
				s.push(null);
				f.push(Std.parseFloat(_reInterpolateNumber.matched(0)));
				value = _reInterpolateNumber.matchedRight();
			}
			if (!Strings.empty(value))
			{
				s.push(value);
				f.push(null);
			}
		}
		var sa = [],
			fa = [],
			sb = [],
			fb = [];
		extract(a, sa, fa);
		extract(b, sb, fb);

		var functions = [], i = 0;
		var min = sa.length < sb.length ? sa.length : sb.length;
		while (i < min)
		{
			if (sa[i] != sb[i])
				break;
			if (null == sa[i])
			{
				if (fa[i] == fb[i]) // no need to interpolate
				{
					var s = "" + fa[i];
					functions.push(function(_) return s);
				} else {
					var f = Floats.interpolatef(fa[i], fb[i], equation);
					functions.push(function(t) return "" + f(t));
				}
			} else {
				var s = sa[i];
				functions.push(function(_) return s);
			}
			i++;
		}
		var rest = "";
		while (i < sb.length)
		{
			if (null != sb[i])
				rest += sb[i];
			else
				rest += fb[i];
			i++;
		}
		if ("" != rest)
			functions.push(function(_) return rest);
		return function(t) {
			var result = [];
			for(fun in functions)
				result.push(fun(t));
			return result.join("");
		};
	}

	public static function interpolateChars(v : Float, a : String, b : String, ?equation : Float -> Float)
	{
		return interpolateCharsf(a, b, equation)(v);
	}

	public static function interpolateCharsf(a : String, b : String, ?equation : Float -> Float) : Float -> String
	{

		var aa = a.split(""),
			ab = b.split("");
		while (aa.length > ab.length)
			ab.insert(0, " ");
		while (ab.length > aa.length)
			aa.insert(0, " ");
		var ai = [];
		for (i in 0...aa.length)
			ai[i] = interpolateCharf(aa[i], ab[i]);
		return function(v)
		{
			var r = [];
			for (i in 0...ai.length)
				r[i] = ai[i](v);
			return StringTools.trim(r.join(""));
		}
	}

	public static function interpolateChar(v : Float, a : String, b : String, ?equation : Float -> Float)
	{
		return interpolateCharf(a, b, equation)(v);
	}

	public static function interpolateCharf(a : String, b : String, ?equation : Float -> Float) : Float -> String
	{
		if (~/^\d/.match(b) && a == ' ') a = '0';
		var r = ~/^[^a-zA-Z0-9]/;
		if (r.match(b) && a == ' ')  a = r.matched(0);
		var ca = a.charCodeAt(0),
			cb = b.charCodeAt(0),
			i = Ints.interpolatef(ca, cb, equation);
		return function(v) return String.fromCharCode(i(v));
	}

	public static function empty(value : String)
	{
		return value == null || value == '';
	}

	static var _reCollapse = ~/\s+/g;
	public static function collapse(value : String)
	{
		return _reCollapse.replace(StringTools.trim(value), " ");
	}
}