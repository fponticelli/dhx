/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

// TODO inline

package dhx;

import js.Dom;
import js.Lib;
import dhx.Namespace;

class Group
{
	public static var current : HtmlDom;
	public var parentNode : HtmlDom;

	var nodes : Array<HtmlDom>;

	public function new(nodes : Array<HtmlDom>) this.nodes = nodes

	public function each(f : HtmlDom -> Int -> Void)
	{
		for (i in 0...nodes.length)
			if (null != nodes[i])
				f(current = nodes[i], i);
	}

	inline public function iterator() return nodes.iterator()

	inline public function get(i : Int) return nodes[i]

	inline public function count() return nodes.length

	inline public function push(node : HtmlDom) nodes.push(node)

	inline public static function merge(source:Array<Group>, target:Array<Group>){
		if (target.length != source.length) throw ("Group length not equal");
		for (i in 0...target.length){
			var s = source[i];
			var t = target[i];
			//if (s.nodes.length != t.nodes.length) Lib.debug();
			for (i in 0...t.nodes.length){
				if (s.nodes[i] == null) continue;
				t.nodes[i] = s.nodes[i]; // override
			}
		}
		return target;
	}

	inline public function sort(comparator : HtmlDom -> HtmlDom -> Int) nodes.sort(comparator)
}
