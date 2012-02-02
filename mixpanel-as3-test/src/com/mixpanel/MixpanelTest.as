package com.mixpanel
{
	import com.mixpanel.Mixpanel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	public class MixpanelTest
	{
		private var mixpanel:Mixpanel;
		private var asyncDispatcher:EventDispatcher;
		
		[Before]
		public function setUp():void
		{
			mixpanel = new Mixpanel("4874fb5a6ac20d3c883349defcfb9c99");
			mixpanel.setConfig({ test: 1 });
			
			asyncDispatcher = new EventDispatcher();
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		private function stop(id:String, timeout:int = 10000):void {
			var handler:Function = Async.asyncHandler(this, function () {}, timeout, {}, function() {
				Assert.fail("async test failed to return within timeout");
			});
			
			asyncDispatcher.addEventListener(id, handler);
		}
		
		private function start(id:String):void {
			asyncDispatcher.dispatchEvent(new Event(id));
		}
				
		[Test(async, description="check track callback")]
		public function track():void {
			var asyncID:String = "track_async1";
			stop(asyncID);
			mixpanel.track("test", {"hello": "world"}, function(resp:String) {
				Assert.assertEquals(parseInt(resp), 1, "server returned success");
				start(asyncID);
			});
		}
		
	}
}