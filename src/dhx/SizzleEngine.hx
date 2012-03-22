/**
 * ...
 * @author Franco Ponticelli
 */

package dhx;
import dhx.ISelectorEngine;
import js.Dom;

class SizzleEngine implements ISelectorEngine
{

	public function new(){}

	public static function supported()
	{
		return false != getSizzle();
	}

	public function select(selector : String, node : HtmlDom) : Null<HtmlDom>
	{
		return Sizzle.select(selector, node)[0];
	}

	public static function getSizzle() : Dynamic
	{
		return untyped __js__("(('undefined' != typeof Sizzle && Sizzle) || (('undefined' != typeof jQuery) && jQuery.find) || (('undefined' != typeof $) && $.find))");
	}

	public function selectAll(selector : String, node : HtmlDom) : Array<HtmlDom>
	{
		return Sizzle.uniqueSort(Sizzle.select(selector, node));
	}
}