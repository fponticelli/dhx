/**
 * ...
 * @author Franco Ponticelli
 */

package dhx;

import js.Browser;
import js.Dom;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class TestSizzle
{
	var node : HtmlDom;
	public function setup()
	{
		node = Lib.document.createElement("div");
		node.id = "testsizzle";
		Lib.document.body.appendChild(node);
	}

	public function teardown()
	{
		Lib.document.body.removeChild(node);
	}

	public function testSizzle()
	{
		var selection = Sizzle.select("#testsizzle");
		Assert.equals(1, selection.length);
		Assert.equals(node, selection[0]);
	}

	public function new(){}
}