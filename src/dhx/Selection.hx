/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

package dhx;

import dhx.Dom;
import js.Dom;
import js.Lib;
import dhx.Namespace;
import dhx.AccessAttribute;
import dhx.AccessClassed;
import dhx.AccessHtml;
import dhx.AccessProperty;
import dhx.AccessStyle;
import dhx.AccessText;
import dhx.Transition;

class Selection extends UnboundSelection<Selection>
{
	public static var current(getCurrent, null) : Selection;
	public static var currentNode(getCurrentNode, null) : HtmlDom;

	public static function create(groups : Array<Group>) return new Selection(groups)
	private function new(groups : Array<Group>) super(groups)
	override function createSelection(groups : Array<Group>) : Selection
	{
		return new Selection(groups);
	}

	inline static function getCurrent() return Dom.selectNode(Group.current)
	inline static function getCurrentNode() return Group.current
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
	public function data<T>(d : Array<T>, ?join : T -> Int -> String) : BoundSelection<T>
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

		return new BoundSelection(groups, {update:update, enter:enter, exit:exit});
	}

	public function selectAllData<T>(selector : String)
	{

		var selection : { private var groups : Array<Group>; } = cast selectAll(selector);
		return new ResumeSelection<T>(selection.groups, {update:[], enter:[], exit:[]});
	}
}


class ResumeSelection<T> extends AbstractBoundSelection<T,ResumeSelection<T>>
{
	public static function create<T>(groups : Array<Group>) return new ResumeSelection<T>(groups, {update:[], enter:[], exit:[]})
	override function createSelection(groups : Array<Group>):ResumeSelection<T>
	{
		return new ResumeSelection<T>(groups, this.selections);
	}
}

typedef GroupSelections ={
	update:Array<Group>,
	enter:Array<Group>,
	exit:Array<Group>
}

class BoundSelection<T> extends AbstractBoundSelection<T,BoundSelection<T>>
{
	public function new(groups:Array<Group>, selections:GroupSelections){
		super(groups, selections);
	}
	override function createSelection(groups : Array<Group>) : BoundSelection<T>
	{
		return new BoundSelection(groups, this.selections );
	}

}

class EnterSelection<T> extends AbstractBoundSelection<T,EnterSelection<T>>
{
	public function new(groups:Array<Group>, selections:GroupSelections){
		super(groups, selections);
	}

	override function createSelection(groups : Array<Group>) : EnterSelection<T>
	{
		var sel = {
			update:groups,
			enter:this.selections.enter.copy(),
			exit:this.selections.exit.copy()
		}
		return new EnterSelection(groups, sel);
	}

}

class AbstractBoundSelection<T,That> extends BaseSelection<That>
{
	private var selections:GroupSelections;
	public function html() return new AccessDataHtml(this)
	public function text() return new AccessDataText(this)
	public function attr(name : String) return new AccessDataAttribute(name, this)
	public function classed() return new AccessDataClassed(this)
	public function property(name : String) return new AccessDataProperty(name, this)
	public function style(name : String) return new AccessDataStyle(name, this)


	// TRANSITION
	public function transition()
	{
		return new BoundTransition<T>(cast this);
	}

	public function new(groups : Array<Group>, selections: GroupSelections)
	{
		this.selections = selections;
		super(groups);
	}



	// DATA BINDING
	public function data<T>(d : Array<T>, ?join : T -> Int -> String) : BoundSelection<T>
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


		return new BoundSelection(groups, {update:update, enter:enter, exit:exit});
	}

	public function dataf<TOut>(fd : T -> Int -> Array<TOut>, ?join : TOut -> Int -> String) : BoundSelection<TOut>
	{
		if (null == join)
		{
			var update = [], enter = [], exit = [], i = 0;
			for (group in groups)
				BaseSelection.bind(group, cast fd(Access.getData(group.parentNode), i++), update, enter, exit);
			return new BoundSelection(groups, {update:update, enter:enter, exit:exit});
		} else {
			var update = [], enter = [], exit = [], i = 0;
			for (group in groups)
				BaseSelection.bindJoin(join, cast group, fd(Access.getData(group.parentNode), i++), update, enter, exit);
			return new BoundSelection(groups, {update:update, enter:enter, exit:exit});
		}
	}

	public function selfData<TOut>()
	{
		return dataf(function(d : T, _) return cast d);
	}

	public function each(f : T -> Int -> Void)
	{
		return eachNode(function(n,i) f(Access.getData(n),i));
	}

	public function sort(comparator : T -> T -> Int)
	{
		return sortNode(function(a,b) return comparator(Access.getData(a), Access.getData(b)));
	}

	public function filter(f : T -> Int -> Bool)
	{
		return filterNode(function(n,i) return f(Access.getData(n),i));
	}

	// TODO: use class type parameter here instead of TIn.
	// This will require overload covariance in upcoming Haxe compiler
	// version
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

	public function on(type : String, ?listener : T -> Int -> Void, capture = false)
	{
		return onNode(type, null == listener ? null : function(n, i) {
			listener(Access.getData(n),i);
		}, capture);
	}

	// Group Selections
	public function enter():PreEnterSelection<T>
	{
		return new PreEnterSelection(selections.enter, selections);
	}

	public function exit():BoundSelection<T>
	{
		return new BoundSelection(selections.exit, selections);
	}

	public function update():BoundSelection<T>
	{
		return new BoundSelection(selections.update, selections);
	}

}

class PreEnterSelection<T>
{
	var groups : Array<Group>;
	var selections : GroupSelections;
	public function new(enter : Array<Group>, selections:GroupSelections)
	{
		this.groups = enter;
		this.selections = selections;
	}

	public function append(name : String)
	{
		var qname = Namespace.qualify(name);
		function append(node : HtmlDom)
		{
			var n : HtmlDom = Lib.document.createElement(name);
			node.appendChild(n);
			return n;
		}

		function appendNS(node : HtmlDom)
		{
			var n : HtmlDom = untyped Lib.document.createElementNS(qname.space, qname.local);
			node.appendChild(n);
			return n;
		}
		return _select(null == qname ? append : appendNS);

	}

	public function insert(name : String, ?before : HtmlDom, ?beforeSelector : String)
	{
		var qname = Namespace.qualify(name);
		function insertDom(node : HtmlDom) {
			var n : HtmlDom = Lib.document.createElement(name),
				bf = null != before ? before : Dom.selectNode(node).select(beforeSelector).node();
			node.insertBefore(n, bf);
			return n;
		}

		function insertNsDom(node : HtmlDom) {
			var n : HtmlDom = untyped js.Lib.document.createElementNS(qname.space, qname.local),
				bf = null != before ? before : Dom.selectNode(node).select(beforeSelector).node();
			node.insertBefore(n, bf);
			return n;
		}

		return _select(null == qname ? insertDom : insertNsDom);
	}

	function createSelection(groups : Array<Group>):EnterSelection<T>
	{
		return new EnterSelection(groups, this.selections);
	}

	function _select(selectf : HtmlDom -> HtmlDom)
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
		Group.merge(subgroups, this.selections.update); // merge changes to the update selection
		return createSelection(subgroups);
	}
}


class BaseSelection<This>
{
	public var parentNode : HtmlDom;

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
		function append(node : HtmlDom)
		{
			var n : HtmlDom = Lib.document.createElement(name);
			node.appendChild(n);
			return n;
		}

		function appendNS(node : HtmlDom)
		{
			var n : HtmlDom = untyped Lib.document.createElementNS(qname.space, qname.local);
			node.appendChild(n);
			return n;
		}

		return _select(null == qname ? append : appendNS);
	}

	public function remove() : This
	{
		return eachNode(function(node : HtmlDom, i : Int)  {
			var parent = node.parentNode;
			if(null != parent)
				parent.removeChild(node);
		});
	}

	public function eachNode(f : HtmlDom -> Int -> Void)
	{
		for (group in groups)
			group.each(f);
		return _this();
	}

	public function insert(name : String, ?before : HtmlDom, ?beforeSelector : String)
	{
		var qname = Namespace.qualify(name);
		function insertDom(node) {
			var n : HtmlDom = Lib.document.createElement(name);
			node.insertBefore(n, null != before ? before : Dom.select(beforeSelector).node());
			return n;
		}

		function insertNsDom(node) {
			var n : HtmlDom = untyped js.Lib.document.createElementNS(qname.space, qname.local);
			node.insertBefore(n, null != before ? before : Dom.select(beforeSelector).node());
			return n;
		}

		return _select(null == qname ? insertDom : insertNsDom);
	}

	public function sortNode(comparator : HtmlDom -> HtmlDom -> Int)
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
	public function firstNode<T>(f : HtmlDom -> T) : Null<T>
	{
		for (group in groups)
			for (node in group)
				if (null != node)
					return f(node);
		return null;
	}

	public function node() : HtmlDom
	{
		return firstNode(function(n) return n);
	}

	public function empty() : Bool
	{
		return null == firstNode(function(n) return n);
	}

	public function filterNode(f : HtmlDom -> Int -> Bool)
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

	public function mapNode<T>(f : HtmlDom -> Int -> T)
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
			target : HtmlDom = untyped e.relatedTarget;
		if(null == target || isChild(dom, target))
			return;
		f(dom, i);
	}

	static function isChild(parent : HtmlDom, child : HtmlDom)
	{
		if (child == parent)
			return false;
		while (child != null)
		{
			child = child.parentNode;
			if (child == parent)
				return true;
		}
		return false;
	}

	// NODE EVENT
	public function onNode(type : String, ?listener : HtmlDom -> Int -> Void, capture = false)
	{
		var i = type.indexOf("."),
			typo = i < 0 ? type : type.substr(0, i);

		if ((typo == "mouseenter" || typo == "mouseleave") && !ClientHost.isIE())
		{
			listener = callback(listenerEnterLeave, listener);
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
	public static dynamic function addEvent(target : HtmlDom, typo : String, handler : Event -> Void, capture : Bool)
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

	public static dynamic function removeEvent(target : HtmlDom, typo : String, type : String, capture : Bool)
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
	inline public static function addEvent(node : HtmlDom, typo : String, handler : Event -> Void, capture : Bool)
	{
		untyped node.addEventListener(typo, handler, capture);
	}

	inline public static function removeEvent(node : HtmlDom, typo : String, type : String, capture : Bool)
	{
		untyped node.removeEventListener(typo, dhx.Access.getEvent(node, type), capture);
	}
#end

	// PRIVATE HELPERS
	function createSelection(groups : Array<Group>) : This
	{
		return throw "abstract method";
	}

	function _select(selectf : HtmlDom -> HtmlDom) : This
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

	function _selectAll(selectallf : HtmlDom -> Array<HtmlDom>) : This
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
			updateHtmlDoms = [],
			exitHtmlDoms = [],
			enterHtmlDoms = [],
			node,
			nodeData
		;
		var nodeByKey = new Hash(),
			keys = [],
			key,
			j = groupData.length;

		for (i in 0...n)
		{
			node = group.get(i);
			key = join(Access.getData(node), i);
//			trace(key + " " + nodeByKey.exists(key));
			if (nodeByKey.exists(key))
			{
				exitHtmlDoms[j++] = node;
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
				updateHtmlDoms[i] = node;
				enterHtmlDoms[i] = exitHtmlDoms[i] = null;
			} else {
				node = Access.emptyHtmlDom(nodeData);
				enterHtmlDoms[i] = node;
				updateHtmlDoms[i] = exitHtmlDoms[i] = null;
			}
			nodeByKey.remove(key);
		}

		for (i in 0...n)
		{
			if (nodeByKey.exists(keys[i]))
				exitHtmlDoms[i] = group.get(i);
		}

		var enterGroup = new Group(enterHtmlDoms);
		enterGroup.parentNode = group.parentNode;
		enter.push(enterGroup);
		var updateGroup = new Group(updateHtmlDoms);
		updateGroup.parentNode = group.parentNode;
		update.push(updateGroup);
		var exitGroup = new Group(exitHtmlDoms);
		exitGroup.parentNode = group.parentNode;
		exit.push(exitGroup);
	}

	static function bind<TData>(group : Group, groupData : Array<TData>, update : Array<Group>, enter : Array<Group>, exit : Array<Group>)
	{
		var n0 = group.count(),
			n1 = group.count(),
			updateHtmlDoms = [],
			exitHtmlDoms = [],
			enterHtmlDoms = [],
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
				updateHtmlDoms[i] = node;
				enterHtmlDoms[i] = exitHtmlDoms[i] = null;
			} else {
				enterHtmlDoms[i] = Access.emptyHtmlDom(nodeData);
				updateHtmlDoms[i] = exitHtmlDoms[i] = null;
			}
		}
		for (i in n0...groupData.length)
		{
			node = Access.emptyHtmlDom(groupData[i]);
			enterHtmlDoms[i] = node;
			updateHtmlDoms[i] = exitHtmlDoms[i] = null;
		}
		for (i in groupData.length...n1)
		{
			exitHtmlDoms[i] = group.get(i);
			enterHtmlDoms[i] = updateHtmlDoms[i] = null;
		}

		var enterGroup = new Group(enterHtmlDoms);
		enterGroup.parentNode = group.parentNode;
		enter.push(enterGroup);
		var updateGroup = new Group(updateHtmlDoms);
		updateGroup.parentNode = group.parentNode;
		update.push(updateGroup);
		var exitGroup = new Group(exitHtmlDoms);
		exitGroup.parentNode = group.parentNode;
		exit.push(exitGroup);
	}
}

