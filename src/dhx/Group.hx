/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

// TODO inline

package dhx;

import js.html.Element;
import js.Browser;
import dhx.Namespace;

class Group
{
	public static var current : Element;
	public var parentNode : Element;

	var nodes : Array<Element>;

	public function new(nodes : Array<Element>) this.nodes = nodes

	public function each(f : Element -> Int -> Void)
	{
		for (i in 0...nodes.length)
			if (null != nodes[i])
				f(current = nodes[i], i);
	}

	inline public function iterator() return nodes.iterator()

	inline public function get(i : Int) return nodes[i]

	inline public function count() return nodes.length

	inline public function push(node : Element) nodes.push(node)

	inline public static function merge(source:Array<Group>, target:Array<Group>){
		if (target.length != source.length) throw ("Group length not equal");
		for (i in 0...target.length){
			var s = source[i];
			var t = target[i];
			if (s.parentNode != t.parentNode) throw ("parentNodes not the same!");
			else if (s.nodes.length != t.nodes.length) throw("node length mismatch!")
			else{
				for (i in 0...t.nodes.length){
					if (null == t.nodes[i]) t.nodes[i] = s.nodes[i];
				}
			}
		}
		return target;
	}

	inline public function sort(comparator : Element -> Element -> Int) nodes.sort(comparator)
}