/**
 * ...
 * @author Franco Ponticelli
 */

package dhx;
import dhx.ISelectorEngine;
import js.Dom;

class NativeSelectorEngine implements ISelectorEngine
{
	public static function supported() : Bool
	{
		return untyped __js__("'undefined' != typeof document.querySelector");
	}

	public function new(){}

	public function select(selector : String, node : HtmlDom) : Null<HtmlDom>
	{
		if(null == node) node = js.Lib.document;
		return untyped node.querySelector(selector);
	}

	public function selectAll(selector : String, node : HtmlDom) : Array<HtmlDom>
	{
		if(null == node) node = js.Lib.document;
		var s : ArrayAccess<HtmlDom> = untyped node.querySelectorAll(selector);
		var r = [];
		for(i in 0...untyped s.length)
			r.push(s[i]);
		return r;
	}
}