/**
 * ...
 * @author Franco Ponticelli
 */

package dhx;
import dhx.ISelectorEngine;
import js.html.Element;
import js.html.Document;

class SizzleEngine implements ISelectorEngine
{

	public function new(){}

	public static function supported()
	{
		return null != getSizzle();
	}

	public function select(selector : String, ?node : Element, ?doc : Document) : Null<Element>
	{
		return Sizzle.select(selector, untyped node || doc)[0];
	}

	public static function getSizzle() : Dynamic
	{
		return untyped __js__("(('undefined' != typeof Sizzle && Sizzle) || (('undefined' != typeof jQuery) && jQuery.find) || (('undefined' != typeof $) && $.find))");
	}

	public function selectAll(selector : String, ?node : Element, ?doc : Document) : Array<Element>
	{
		return Sizzle.uniqueSort(Sizzle.select(selector, untyped node || doc));
	}
}