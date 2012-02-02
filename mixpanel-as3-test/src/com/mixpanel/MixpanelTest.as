package com.mixpanel
{
	import com.mixpanel.Mixpanel;
	
	import org.flexunit.Assert;
	
	public class MixpanelTest
	{
		private var mixpanel:Mixpanel;
		
		[Before]
		public function setUp():void
		{
			mixpanel = new Mixpanel("4874fb5a6ac20d3c883349defcfb9c99");
		}
		
		[After]
		public function tearDown():void
		{
		}
				
		[Test]
		public function track():void {
			mixpanel.track("test", {"hello": "world"}, function(resp:*):void {
				trace(resp);
			});
		}
		
	}
}