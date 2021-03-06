/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

package dhx;

import js.Dom;
import dhx.Selection;

class Access<That>
{
	static inline var FIELD_DATA       = '__dhx_data__';
	static inline var FIELD_EVENT      = '__dhx_on__';
	static inline var FIELD_TRANSITION = '__dhx_transition__';

	var selection : BaseSelection<That>;
	public function new(selection : BaseSelection<That>)
	{
		this.selection = selection;
	}

	inline function _that() : That return cast selection

	inline public static function getData(d : HtmlDom) : Dynamic return Reflect.field(d, FIELD_DATA)
	inline public static function setData(d : HtmlDom, v : Dynamic) Reflect.setField(d, FIELD_DATA, v)
	inline public static function emptyHtmlDom(v : Dynamic) : HtmlDom return cast { __dhx_data__ : v }

	inline public static function eventName(event : String) return FIELD_EVENT + event
	inline public static function getEvent(d : HtmlDom, event : String) return Reflect.field(d, eventName(event))
	inline public static function hasEvent(d : HtmlDom, event : String) return null != Reflect.field(d, eventName(event))
	inline public static function addEvent(d : HtmlDom, event : String, listener : Event -> Void) Reflect.setField(d, dhx.Access.eventName(event), listener)
	inline public static function removeEvent(d : HtmlDom, event : String) Reflect.deleteField(d, eventName(event))

	inline public static function setTransition(d : HtmlDom, id : Int)
	{
		if (Reflect.hasField(d, FIELD_TRANSITION))
			Reflect.field(d, FIELD_TRANSITION).owner = id;
		else
			Reflect.setField(d, FIELD_TRANSITION, { owner : id } );
	}
	inline public static function getTransition(d : HtmlDom) : { owner : Int, active : Int } return Reflect.field(d, FIELD_TRANSITION)
	inline public static function resetTransition(d : HtmlDom) Reflect.deleteField(d, FIELD_TRANSITION)
}