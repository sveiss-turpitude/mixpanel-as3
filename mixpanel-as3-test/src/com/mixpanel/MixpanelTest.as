package com.mixpanel
{
	import com.mixpanel.Mixpanel;
	
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
		
		private function stop(timeout:int):void {
			var handler:Function = Async.asyncHandler(this, function () {}, timeout, {}, function() {
				Assert.fail("async test failed to return within timeout");
			});
			
			var id:String = Math.random().toString();
			asyncDispatcher.addEventListener(id, handler);
		}
		
		private function start():void {
			asyncDispatcher.dispatchEvent("start");
		}
				
		[Test(async, description="check track callback")]
		public function track():void {
			stop();
			mixpanel.track("test", {"hello": "world"}, function(resp:String) {
				Assert.assertEquals(parseInt(resp), 1, "server returned success");
				start();
			});
		}
		
	}
}