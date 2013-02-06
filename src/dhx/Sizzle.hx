package dhx;

import js.html.Element;

extern class Sizzle
{
	public static function select(selector : String, ?doc : Element, ?result : Array<Element>) : Array<Element>;
	public static function uniqueSort(list : Array<Element>) : Array<Element>;

	private static function __init__() : Void untyped {
		#if embed_js
		haxe.macro.Compiler.includeFile("dhx/sizzle.js");
		#end
		var s : Dynamic = SizzleEngine.getSizzle();
		dhx.Sizzle = s;
		dhx.Sizzle.select = s;
	}
}