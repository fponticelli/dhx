package dhx;

import js.html.Element;
import js.html.Document;

interface ISelectorEngine
{
	public function select(selector : String, ?node : Element, ?doc : Document) : Null<Element>;
	public function selectAll(selector : String, ?node : Element, ?doc : Document) : Array<Element>;
}