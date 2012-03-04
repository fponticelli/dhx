/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

package dhx;

import js.Dom;
import dhx.Transition;
#if !thx
import dhx.util.Strings;
import dhx.util.Floats;
#end

class AccessTween<That : BaseTransition<Dynamic>>
{
	var transition : BaseTransition<That>;
	var tweens : Hash<HtmlDom -> Int -> (Float -> Void)>;
	public function new(transition : BaseTransition<That>, tweens : Hash<HtmlDom -> Int -> (Float -> Void)>)
	{
		this.transition = transition;
		this.tweens = tweens;
	}
#if thx
	function transitionColorTween(value : thx.color.Rgb)
	{
		return function(d : HtmlDom, i : Int, a : thx.color.Rgb) return thx.color.Rgb.interpolatef(a, value);
	}

	function transitionColorTweenf(f : HtmlDom -> Int -> thx.color.Rgb)
	{
		return function(d : HtmlDom, i : Int, a : thx.color.Rgb) return thx.color.Rgb.interpolatef(a, f(d,i));
	}
#end
	function transitionStringTween(value : String)
	{
		return function(d : HtmlDom, i : Int, a : String) return Strings.interpolatef(a, value);
	}

	function transitionStringTweenf(f : HtmlDom -> Int -> String)
	{
		return function(d : HtmlDom, i : Int, a : String) return Strings.interpolatef(a, f(d,i));
	}

	function transitionCharsTween(value : String)
	{
		return function(d : HtmlDom, i : Int, a : String) return Strings.interpolateCharsf(a, value);
	}

	function transitionCharsTweenf(f : HtmlDom -> Int -> String)
	{
		return function(d : HtmlDom, i : Int, a : String) return Strings.interpolateCharsf(a, f(d,i));
	}

	function transitionFloatTween(value : Float)
	{
		return function(d : HtmlDom, i : Int, a : Float) return Floats.interpolatef(a, value);
	}

	function transitionFloatTweenf(f : HtmlDom -> Int -> Float)
	{
		return function(d : HtmlDom, i : Int, a : Float) return Floats.interpolatef(a, f(d,i));
	}

	inline function _that() : That return cast transition
}