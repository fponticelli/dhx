/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

package dhx;

import dhx.Dom;
import dhx.Namespace;
import dhx.AccessAttribute;
import dhx.AccessClassed;
import dhx.AccessHtml;
import dhx.AccessProperty;
import dhx.AccessStyle;
import dhx.AccessText;
import dhx.Transition;
import js.html.Element;
import js.html.Event;

class Selection extends UnboundSelection<Selection>
{
	public static var current(get, null) : Selection;
	public static var currentNode(get, null) : Element;

	public static function create(groups : Array<Group>) return new Selection(groups)
	private function new(groups : Array<Group>) super(groups)
	override function createSelection(groups : Array<Group>) : Selection
	{
		return new Selection(groups);
	}

	inline static function get_current() return Dom.selectNode(Group.current)
	inline static function get_currentNode() return Group.current
/*
#if (js && js_shims)
	static function __init__()
	{
		untyped __js__("if(!('createElementNS' in document))
	document.createElementNS = function(_, name) { return document.createElement(name); }
var N = window.DOMElement || window.Element;
if (!('setAttributeNS' in N.prototype))
	N.prototype.setAttributeNS = function(_, attr, v){ return this.setAttribute(attr, v); }
if (!('getAttributeNS' in N.prototype))
	N.prototype.getAttributeNS = function(_, attr){ return this.getAttribute(attr); }
//delete N;
");
	}
#end
*/
}

class UnboundSelection<This> extends BaseSelection<This>
{
	public function html() return new AccessHtml(this)
	public function text() return new AccessText(this)
	public function attr(name : String) return new AccessAttribute(name, this)
	public function classed() return new AccessClassed(this)
	public function property(name : String) return new AccessProperty(name, this)
	public function style(name : String) return new AccessStyle(name, this)

	// TRANSITION

	public function transition()
	{
		return new UnboundTransition(this);
	}

	// DATA BINDING
	public function data<T>(d : Array<T>, ?join : T -> Int -> String) : DataChoice<T>
	{
		var update = [], enter = [], exit = [];

		if (null == join)
		{
			for (group in groups)
				BaseSelection.bind(group, d, update, enter, exit);
		} else {
			for (group in groups)
				BaseSelection.bindJoin(join, group, d, update, enter, exit);
		}

		return new DataChoice(update, enter, exit);
	}

	public function selectAllData<T>(selector : String)
	{
		var selection : { private var groups : Array<Group>; } = cast selectAll(selector);
		return new ResumeSelection<T>(selection.groups);
	}
}

class DataChoice<T> extends UpdateSelection<T>
{
	var _update : Array<Group>;
	var _enter : Array<Group>;
	var _exit : Array<Group>;
	public function new(update : Array<Group>, enter : Array<Group>, exit : Array<Group>)
	{
		_update = update;
		_enter = enter;
		_exit = exit;
		super(_update,this);
	}

	override public function enter()
	{
		return new PreEnterSelection(_enter, this);
	}

	override public function exit()
	{
		return new ExitSelection(_exit, this);
	}

/*	public function update()
	{
		return new UpdateSelection(_update, this);
	}
*/

	public static function merge<T>(groups:Array<Group>,dc:DataChoice<T>){
		Group.merge(groups, dc._update);
	}

}

class ResumeSelection<T> extends BoundSelection<T, ResumeSelection<T>>
{
	public static function create<T>(groups : Array<Group>) return new ResumeSelection<T>(groups)
	override function createSelection(groups : Array<Group>)
	{
		return new ResumeSelection<T>(groups);
	}
}

class BoundSelection<T, This> extends BaseSelection<This>
{
	public function html() return new AccessDataHtml(this)
	public function text() return new AccessDataText(this)
	public function attr(name : String) return new AccessDataAttribute(name, this)
	public function classed() return new AccessDataClassed(this)
	public function property(name : String) return new AccessDataProperty(name, this)
	public function style(name : String) return new AccessDataStyle(name, this)

	// TRANSITION
	public function transition()
	{
		return new BoundTransition<T>(this);
	}

	public function new(groups : Array<Group>)
	{
		super(groups);
	}

	// DATA BINDING
	public function data<T>(d : Array<T>, ?join : T -> Int -> String) : DataChoice<T>
	{
		var update = [], enter = [], exit = [];

		if (null == join)
		{
			for (group in groups)
				BaseSelection.bind(group, d, update, enter, exit);
		} else {
			for (group in groups)
				BaseSelection.bindJoin(join, group, d, update, enter, exit);
		}

		return new DataChoice(update, enter, exit);
	}

	public function dataf<TOut>(fd : T -> Int -> Array<TOut>, ?join : TOut -> Int -> String) : DataChoice<TOut>
	{
		if (null == join)
		{
			var update = [], enter = [], exit = [], i = 0;
			for (group in groups)
				BaseSelection.bind(group, cast fd(Access.getData(group.parentNode), i++), update, enter, exit);
			return new DataChoice(cast update, cast enter, cast exit);
		} else {
			var update = [], enter = [], exit = [], i = 0;
			for (group in groups)
				BaseSelection.bindJoin(join, cast group, fd(Access.getData(group.parentNode), i++), update, enter, exit);
			return new DataChoice(update, enter, exit);
		}
	}

	public function selfData<TOut>()
	{
		return dataf(function(d : T, _) return cast d);
	}

	public function each<T>(f : T -> Int -> Void)
	{
		return eachNode(function(n,i) f(Access.getData(n),i));
	}

	public function sort<T>(comparator : T -> T -> Int)
	{
		return sortNode(function(a,b) return comparator(Access.getData(a), Access.getData(b)));
	}

	public function filter<T>(f : T -> Int -> Bool)
	{
		return filterNode(function(n,i) return f(Access.getData(n),i));
	}

	public function map<TIn, TOut>(f : TIn -> Int -> TOut)
	{
		var ngroups = [];
		for (group in groups)
		{
			var ngroup = new Group([]);
			var i = 0;
			for (node in group)
			{
				if (null != node)
					Access.setData(node, f(Access.getData(node), i++));
				ngroup.push(node);
			}
			ngroups.push(ngroup);
		}
		return createSelection(ngroups);
	}

	public function first<TIn, TOut>(f : TIn -> TOut) : TOut
	{
		return firstNode(function(n) return f(Access.getData(n)));
	}

	public function on<T>(type : String, ?listener : T -> Int -> Void, capture = false)
	{
		return onNode(type, null == listener ? null : function(n, i) {
			listener(Access.getData(n),i);
		}, capture);
	}
}

class PreEnterSelection<T>
{
	var groups : Array<Group>;
	var _choice : DataChoice<T>;
	public function new(enter : Array<Group>, choice : DataChoice<T>)
	{
		this.groups = enter;
		this._choice = choice;
	}

	public function append(name : String)
	{
		var qname = Namespace.qualify(name);
		function append(node : Element)
		{
			var n : Element = js.Browser.document.createElement(name);
			node.appendChild(n);
			return n;
		}

		function appendNS(node : Element)
		{
			var n : Element = untyped js.Browser.document.createElementNS(qname.space, qname.local);
			node.appendChild(n);
			return n;
		}
		return _select(null == qname ? append : appendNS);

	}

	public function insert(name : String, ?before : Element, ?beforeSelector : String)
	{
		var qname = Namespace.qualify(name);
		function insertDom(node : Element) {
			var n : Element = js.Browser.document.createElement(name),
				bf = null != before ? before : Dom.selectNode(node).select(beforeSelector).node();
			node.insertBefore(n, bf);
			return n;
		}

		function insertNsDom(node : Element) {
			var n : Element = untyped js.js.Browser.document.createElementNS(qname.space, qname.local),
				bf = null != before ? before : Dom.selectNode(node).select(beforeSelector).node();
			node.insertBefore(n, bf);
			return n;
		}

		return _select(null == qname ? insertDom : insertNsDom);
	}

	function createSelection(groups : Array<Group>)
	{
		return new EnterSelection(groups, _choice);
	}

	function _select(selectf : Element -> Element)
	{
		var subgroups = [],
			subgroup,
			subnode,
			node;
		for (group in groups)
		{
			subgroups.push(subgroup = new Group([]));
			subgroup.parentNode = group.parentNode;
			for (node in group)
			{
				if (null != node)
				{

					subgroup.push(subnode = selectf(group.parentNode));
					Access.setData(subnode, Access.getData(node));
				} else {
					subgroup.push(null);
				}
			}
		}
		DataChoice.merge(subgroups, _choice);
		return createSelection(subgroups);
	}
}

class EnterSelection<T> extends BoundSelection<T, EnterSelection<T>>
{
	var _choice : DataChoice<T>;
	public function new(enter : Array<Group>, choice : DataChoice<T>)
	{
		super(enter);
		this._choice = choice;
	}

	override function createSelection(groups : Array<Group>)
	{
		return new EnterSelection(groups, _choice);
	}
	public function exit() return _choice.exit()
	public function update() return _choice.update()
}

class ExitSelection<T> extends UnboundSelection<ExitSelection<T>>
{
	var _choice : DataChoice<T>;
	public function new(exit : Array<Group>, choice : DataChoice<T>)
	{
		super(exit);
		this._choice = choice;
	}

	override function createSelection(groups : Array<Group>)
	{
		return new ExitSelection(groups, _choice);
	}

	public function enter() return _choice.enter()
	public function update() return _choice.update()
}

class UpdateSelection<T> extends BoundSelection<T, UpdateSelection<T>>
{
	var _choice : DataChoice<T>;
	public function new(update : Array<Group>, choice : DataChoice<T>)
	{
		super(update);
		this._choice = choice;
	}

	override function createSelection(groups : Array<Group>)
	{
		return new UpdateSelection(groups, _choice);
	}

	public function update() return this
	public function enter() return _choice.enter()
	public function exit() return _choice.exit()
}

class BaseSelection<This>
{
	public var parentNode : Element;

	var groups : Array<Group>;

	function new(groups : Array<Group>)
	{
		this.groups = groups;
	}

	// SELECTION
	public function select(selector : String) : This
	{
		return _select(function(el) {
			return Dom.selectionEngine.select(selector, el);
		});
	}

	public function selectAll(selector : String) : This
	{
		return _selectAll(function(el) {
			return Dom.selectionEngine.selectAll(selector, el);
		});
	}

	inline function _this() : This return cast this

	// DOM MANIPULATION
	public function append(name : String) : This
	{
		var qname = Namespace.qualify(name);
		function append(node : Element)
		{
			var n : Element = js.Browser.document.createElement(name);
			node.appendChild(n);
			return n;
		}

		function appendNS(node : Element)
		{
			var n : Element = untyped js.Browser.document.createElementNS(qname.space, qname.local);
			node.appendChild(n);
			return n;
		}

		return _select(null == qname ? append : appendNS);
	}

	public function remove() : This
	{
		return eachNode(function(node : Element, i : Int)  {
			var parent = node.parentNode;
			if(null != parent)
				parent.removeChild(node);
		});
	}

	public function eachNode(f : Element -> Int -> Void)
	{
		for (group in groups)
			group.each(f);
		return _this();
	}

	public function insert(name : String, ?before : Element, ?beforeSelector : String)
	{
		var qname = Namespace.qualify(name);
		function insertDom(node) {
			var n : Element = js.Browser.document.createElement(name);
			node.insertBefore(n, null != before ? before : Dom.select(beforeSelector).node());
			return n;
		}

		function insertNsDom(node) {
			var n : Element = untyped js.js.Browser.document.createElementNS(qname.space, qname.local);
			node.insertBefore(n, null != before ? before : Dom.select(beforeSelector).node());
			return n;
		}

		return _select(null == qname ? insertDom : insertNsDom);
	}

	public function sortNode(comparator : Element -> Element -> Int)
	{
		var m = groups.length;
		for (i in 0...m)
		{
			var group = groups[i];
			group.sort(comparator);
			var n = group.count();
			var prev = group.get(0);
			for (j in 1...n)
			{
				var node = group.get(j);
				if (null != node)
				{
					if (null != prev)
						prev.parentNode.insertBefore(node, prev.nextSibling);
					prev = node;
				}
			}
		}
		return this;
	}

	// NODE QUERY
	public function firstNode<T>(f : Element -> T) : Null<T>
	{
		for (group in groups)
			for (node in group)
				if (null != node)
					return f(node);
		return null;
	}

	public function node() : Element
	{
		return firstNode(function(n) return n);
	}

	public function empty() : Bool
	{
		return null == firstNode(function(n) return n);
	}

	public function filterNode(f : Element -> Int -> Bool)
	{
		var subgroups = [],
			subgroup;
		for (group in groups)
		{
			var sg = new Group(subgroup = []);
			sg.parentNode = group.parentNode;
			subgroups.push(sg);
			var i = -1;
			for (node in group)
			{
				if (null != node && f(node, ++i))
				{
					subgroup.push(node);
				}
			}

		}
		return createSelection(subgroups);
	}

	public function mapNode<T>(f : Element -> Int -> T)
	{
		var results = [];
		for (group in groups)
		{
			var i = -1;
			for (node in group)
			{
				if (null != node)
				{
					results.push(f(node, ++i));
				}
			}

		}
		return results;
	}

	static function listenerEnterLeave(f, dom, i)
	{
		var e = Dom.event,
			target : Element = untyped e.relatedTarget;
		if(null == target || isChild(dom, target))
			return;
		f(dom, i);
	}

	static function isChild(parent : Element, child : Element)
	{
		if (child == parent)
			return false;
		while (child != null)
		{
			child = cast child.parentNode;
			if (child == parent)
				return true;
		}
		return false;
	}

	// NODE EVENT
	public function onNode(type : String, ?listener : Element -> Int -> Void, capture = false)
	{
		var i = type.indexOf("."),
			typo = i < 0 ? type : type.substr(0, i);

		if ((typo == "mouseenter" || typo == "mouseleave") && !ClientHost.isIE())
		{
#if haxe3
			listener = listenerEnterLeave.bind(listener);
#else
			listener = callback(listenerEnterLeave, listener);
#end
			if (typo == "mouseenter")
			{
				typo = "mouseover";
			} else {
				typo = "mouseout";
			}
		}

		return eachNode(function(n, i) {
			function l(e) {
				var o = Dom.event;
				Dom.event = e;
				try
				{
					listener(n, i);
				} catch (e : Dynamic) { }
				Dom.event = o;
			}
			if (Access.hasEvent(n, type))
			{
				removeEvent(n, typo, type, capture);
//				untyped n.removeEventListener(typo, dhx.Access.getEvent(n, type), capture);
				Access.removeEvent(n, type);
			}
			if (null != listener)
			{
				Access.addEvent(n, type, l);
				addEvent(n, typo, l, capture);
//				untyped n.addEventListener(typo, l, capture);
			}
		});
	}
#if (js && js_shims)
	public static dynamic function addEvent(target : Element, typo : String, handler : Event -> Void, capture : Bool)
	{
		untyped if (target.addEventListener != null)
		{
			addEvent = function(target, typo, handler, capture) {
				target.addEventListener(typo, handler, capture);
			};
		} else if (target.attachEvent != null ) {
			addEvent = function(target, typo, handler, capture) {
				target.attachEvent(typo, handler);
			};
		}
		addEvent(target, typo, handler, capture);
	}

	public static dynamic function removeEvent(target : Element, typo : String, type : String, capture : Bool)
	{
		untyped if (target.removeEventListener != null)
		{
			removeEvent = function(target, typo, type, capture) {
				target.removeEventListener(typo, dhx.Access.getEvent(target, type), false);
			};
		} else if (target.attachEvent != null ) {
			removeEvent = function(target, typo, type, capture) {
				target.detachEvent(typo, dhx.Access.getEvent(target, type));
			};
		}
		removeEvent(target, typo, type, capture);
	}
#else
	inline public static function addEvent(node : Element, typo : String, handler : Event -> Void, capture : Bool)
	{
		untyped node.addEventListener(typo, handler, capture);
	}

	inline public static function removeEvent(node : Element, typo : String, type : String, capture : Bool)
	{
		untyped node.removeEventListener(typo, dhx.Access.getEvent(node, type), capture);
	}
#end

	// PRIVATE HELPERS
	function createSelection(groups : Array<Group>) : This
	{
		return throw "abstract method";
	}

	function _select(selectf : Element -> Element) : This
	{
		var subgroups = [],
			subgroup,
			subnode,
			node;
		for (group in groups)
		{
			subgroups.push(subgroup = new Group([]));
			subgroup.parentNode = group.parentNode;
			for (node in group)
			{
				if (null != node)
				{
					subgroup.parentNode = node;
					subgroup.push(subnode = selectf(node));
					if (null != subnode)
						Access.setData(subnode, Access.getData(node)); // TODO: this should probably be moved to BoundSelection
				} else {
					subgroup.push(null);
				}
			}
		}
		return createSelection(subgroups);
	}

	function _selectAll(selectallf : Element -> Array<Element>) : This
	{
		var subgroups = [],
			subgroup;
		for (group in groups)
		{
			for (node in group)
			{
				if (null != node)
				{
					subgroups.push(subgroup = new Group(selectallf(node)));
					subgroup.parentNode = node;
				}
			}
		}
		return createSelection(subgroups);
	}

	static function bindJoin<TData>(join : TData -> Int -> String, group : Group, groupData : Array<TData>, update : Array<Group>, enter : Array<Group>, exit : Array<Group>)
	{
		var n = group.count(),
			m = groupData.length,
			updateElements = [],
			exitElements = [],
			enterElements = [],
			node,
			nodeData
		;
		var nodeByKey = new Map (),
			keys = [],
			key,
			j = groupData.length;

		for (i in 0...n)
		{
			node = group.get(i);
			key = join(Access.getData(node), i);
			if (nodeByKey.exists(key))
			{
				exitElements[j++] = node;
			} else {
				nodeByKey.set(key, node);
			}
			keys.push(key);
		}

		for (i in 0...m)
		{
			node = nodeByKey.get(key = join(nodeData = groupData[i], i));
			if (null != node)
			{
				Access.setData(node, nodeData);
				updateElements[i] = node;
				enterElements[i] = exitElements[i] = null;
			} else {
				node = Access.emptyElement(nodeData);
				enterElements[i] = node;
				updateElements[i] = exitElements[i] = null;
			}
			nodeByKey.remove(key);
		}

		for (i in 0...n)
		{
			if (nodeByKey.exists(keys[i]))
				exitElements[i] = group.get(i);
		}

		var enterGroup = new Group(enterElements);
		enterGroup.parentNode = group.parentNode;
		enter.push(enterGroup);
		var updateGroup = new Group(updateElements);
		updateGroup.parentNode = group.parentNode;
		update.push(updateGroup);
		var exitGroup = new Group(exitElements);
		exitGroup.parentNode = group.parentNode;
		exit.push(exitGroup);
	}

	static function bind<TData>(group : Group, groupData : Array<TData>, update : Array<Group>, enter : Array<Group>, exit : Array<Group>)
	{
		var n0 = group.count(),
			n1 = group.count(),
			updateElements = [],
			exitElements = [],
			enterElements = [],
			node,
			nodeData
		;

		if(n0 > groupData.length) n0 = groupData.length;
		if(n1 < groupData.length) n1 = groupData.length;

		for (i in 0...n0)
		{
			node = group.get(i);
			nodeData = groupData[i];
			if (null != node)
			{
				Access.setData(node, nodeData);
				updateElements[i] = node;
				enterElements[i] = exitElements[i] = null;
			} else {
				enterElements[i] = Access.emptyElement(nodeData);
				updateElements[i] = exitElements[i] = null;
			}
		}
		for (i in n0...groupData.length)
		{
			node = Access.emptyElement(groupData[i]);
			enterElements[i] = node;
			updateElements[i] = exitElements[i] = null;
		}
		for (i in groupData.length...n1)
		{
			exitElements[i] = group.get(i);
			enterElements[i] = updateElements[i] = null;
		}

		var enterGroup = new Group(enterElements);
		enterGroup.parentNode = group.parentNode;
		enter.push(enterGroup);
		var updateGroup = new Group(updateElements);
		updateGroup.parentNode = group.parentNode;
		update.push(updateGroup);
		var exitGroup = new Group(exitElements);
		exitGroup.parentNode = group.parentNode;
		exit.push(exitGroup);
	}
}