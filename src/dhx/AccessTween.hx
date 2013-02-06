/**
 * Based on D3.js by Michael Bostock
 * @author Franco Ponticelli
 */

package dhx;

import js.html.Element;
import dhx.Transition;
#if !thx
import dhx.util.Strings;
import dhx.util.Floats;
#end

class AccessTween<That : BaseTransition<Dynamic>>
{
	var transition : BaseTransition<That>;
	var tweens : Map<String, Element -> Int -> (Float -> Void)>;
	public function new(transition : BaseTransition<That>, tweens : Map<String, Element -> Int -> (Float -> Void)>)
	{
		this.transition = transition;
		this.tweens = tweens;
	}
#if thx
	function transitionColorTween(value : thx.color.Rgb)
	{
		return function(d : Element, i : Int, a : thx.color.Rgb) return thx.color.Rgb.interpolatef(a, value);
	}

	function transitionColorTweenf(f : Element -> Int -> thx.color.Rgb)
	{
		return function(d : Element, i : Int, a : thx.color.Rgb) return thx.color.Rgb.interpolatef(a, f(d,i));
	}
#end
	function transitionStringTween(value : String)
	{
		return function(d : Element, i : Int, a : String) return Strings.interpolatef(a, value);
	}

	function transitionStringTweenf(f : Element -> Int -> String)
	{
		return function(d : Element, i : Int, a : String) return Strings.interpolatef(a, f(d,i));
	}

	function transitionCharsTween(value : String)
	{
		return function(d : Element, i : Int, a : String) return Strings.interpolateCharsf(a, value);
	}

	function transitionCharsTweenf(f : Element -> Int -> String)
	{
		return function(d : Element, i : Int, a : String) return Strings.interpolateCharsf(a, f(d,i));
	}

	function transitionFloatTween(value : Float)
	{
		return function(d : Element, i : Int, a : Float) return Floats.interpolatef(a, value);
	}

	function transitionFloatTweenf(f : Element -> Int -> Float)
	{
		return function(d : Element, i : Int, a : Float) return Floats.interpolatef(a, f(d,i));
	}

	inline function _that() : That return cast transition
}