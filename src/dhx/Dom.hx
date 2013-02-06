/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

package dhx;

import js.html.Element;
import js.html.Event;
import js.Browser;
import dhx.Selection;

class Dom
{

	public static var doc : Selection = (function() {
		var g = new Group([cast Browser.document]),
			gs = Selection.create([g]);
		g.parentNode = gs.parentNode = untyped Browser.document.documentElement;
		return gs;
	})();

	public static var selectionEngine : ISelectorEngine = {
		var engine : ISelectorEngine;
		if(NativeSelectorEngine.supported())
			engine = new NativeSelectorEngine();
		else if(SizzleEngine.supported())
			engine = new SizzleEngine();
		else
			throw "no selector engine available";
		engine;
	}

	public static function select(selector : String) : Selection
	{
		return doc.select(selector);
	}

	public static function selectAll(selector : String) : Selection
	{
		return doc.selectAll(selector);
	}

	public static function selectNode(node : Element) : Selection
	{
		return Selection.create([new Group([node])]);
	}

	public static function selectNodes(nodes : Array<Element>) : Selection
	{
		return Selection.create([new Group(nodes)]);
	}

	public static function selectNodeData<T>(node : Element) : ResumeSelection<T>
	{
		return ResumeSelection.create([new Group([node])]);
	}

	public static var event : Event;
}