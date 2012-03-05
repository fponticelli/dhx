/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

package dhx;

class Namespace
{
	public static var prefix = (function() {
		var h = new Hash();
		h.set("svg",	"http://www.w3.org/2000/svg");
		h.set("xhtml",	"http://www.w3.org/1999/xhtml");
		h.set("xlink",	"http://www.w3.org/1999/xlink");
		h.set("xml",	"http://www.w3.org/XML/1998/namespace");
		h.set("xmlns",	"http://www.w3.org/2000/xmlns/");
		return h;
	})();

	public static function qualify(name : String)
	{
		var i = name.indexOf(":");
		if (i < 0)
			return null;
		else {
			var space = prefix.get(name.substr(0, i));
			if (null == space)
				throw "unable to find a namespace for " + space;
			return new NSQualifier(space, name.substr(i+1));
		}
	}
}

class NSQualifier
{
	public var space : Null<String>;
	public var local : String;
	public function new(space : Null<String>, local : String)
	{
		this.space = space;
		this.local = local;
	}
}