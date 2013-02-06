/**
 * ...
 * @author Franco Ponticelli
 */

package dhx;
import dhx.ISelectorEngine;
import js.html.Element;
import js.html.Document;
import js.html.NodeList;

class NativeSelectorEngine implements ISelectorEngine
{
	public static function supported() : Bool
	{
		return untyped __js__("'undefined' != typeof document.querySelector");
	}

	public function new(){}

	public function select(selector : String, ?node : Element, ?doc : Document) : Null<Element>
	{
		if(null != node) return node.querySelector(selector);
		if(null == doc)
			doc = js.Browser.document;
		return doc.querySelector(selector);
	}

	public function selectAll(selector : String, ?node : Element, ?doc : Document) : Array<Element>
	{
		var s : NodeList;
		if(null != node)
			s = node.querySelectorAll(selector);
		else {
			if(null == doc)
				doc = js.Browser.document;
			s = doc.querySelectorAll(selector);
		}
		var r : Array<Element> = [];
		for(i in 0...untyped s.length)
			r.push(cast s[i]);
		return r;
	}
}