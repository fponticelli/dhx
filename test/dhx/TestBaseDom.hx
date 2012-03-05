/**
 * ...
 * @author Franco Ponticelli
 */

package dhx;

class TestBaseDom
{
	var sel : Selection;

	public function setup()
	{
		sel = Dom.doc.select("body").append("div");
	}

	public function teardown()
	{
		sel.remove();
	}

	public function new() { }
}