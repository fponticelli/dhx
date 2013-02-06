/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

package dhx;

import js.html.Element;
import dhx.Dom;
import js.Browser;

class Svg
{
	static var _usepage = (~/WebKit/).match(Browser.window.navigator.userAgent);
	public static function mouse(dom : Element)
	{
		var point : {x : Float, y : Float} = untyped (null != dom.ownerSVGElement ? dom.ownerSVGElement : dom).createSVGPoint();
		if (_usepage && untyped (Browser.window.scrollX || Browser.window.scrollY))
		{
			var svg = Dom.selectNode(Browser.document.body)
				.append("svg:svg")
					.style("position").string("absolute")
					.style("top").float(0)
					.style("left").float(0);
			var ctm = untyped svg.node().getScreenCTM();
			_usepage = !(ctm.f || ctm.e);
			svg.remove();
		}
		if (_usepage)
		{
			point.x = untyped Dom.event.pageX;
			point.y = untyped Dom.event.pageY;
		} else {
			point.x = untyped Dom.event.clientX;
			point.y = untyped Dom.event.clientY;
		}
		point = untyped point.matrixTransform(dom.getScreenCTM().inverse());
		return [point.x, point.y];
	}
}