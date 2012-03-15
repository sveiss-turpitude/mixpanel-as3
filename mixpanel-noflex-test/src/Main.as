package
{
	
	import com.mixpanel.Mixpanel;
	
	import flash.display.Sprite;

	[SWF(width="500", height="500")]
	public class Main extends Sprite
	{
		public function Main()
		{
			var mp:Mixpanel = new Mixpanel("hello_world");
			mp.track("work!");
			
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0x000000);
			s.graphics.drawCircle(10,10,10);
			s.graphics.endFill();
			
			addChild(s);
			
			
		}
	}
}