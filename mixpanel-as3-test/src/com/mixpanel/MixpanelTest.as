package com.mixpanel
{
	import com.mixpanel.Mixpanel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	public class MixpanelTest
	{
		private var mixpanel:Mixpanel;
		private var asyncDispatcher:EventDispatcher;
		private static var asyncIDCounter:int = 0;
		
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
		
		private function asyncHandler(callback:Function, timeout:int = 10000):int {
			var _this:MixpanelTest = this;
			var handler:Function = Async.asyncHandler(this, function(evt:AsyncEvent, ...ignore):void {
				callback.apply(_this, evt.args); 				
			}, timeout, {}, function():void {
				Assert.fail("async test failed to return within timeout");
			});
			
			var id:int = asyncIDCounter++;
			asyncDispatcher.addEventListener(id.toString(), handler);
			
			return id;
		}
		
		private function start(id:int, ...args):void {
			asyncDispatcher.dispatchEvent(new AsyncEvent(id.toString(), args));
		}
		
		[Test(async, description="check track callback")]
		public function track():void {
			var asyncID:int = asyncHandler(function(resp:String):void {
				Assert.assertEquals("server returned success", resp, "1");
			});
			
			mixpanel.track("test_track", {"hello": "world"}, function(resp:String):void {	
				start(asyncID, resp);
			});
		}
		
		[Test(async, description="check parallel track()'s")]
		public function track_multiple():void {
			var result:Array = [];
			
			mixpanel.track("test_multiple", function(resp:String):void { 
				result.push(1);
			});
			mixpanel.track("test_multiple", function(resp:String):void {
				result.push(2);
			});
			
			Async.delayCall(this, function():void {
				Assert.assertTrue("Both track()'s failed to fire", result.indexOf(1) != -1 && result.indexOf(2) != -1);
			}, 2000);
		}
		
	}
}