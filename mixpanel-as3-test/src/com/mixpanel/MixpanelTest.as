package com.mixpanel
{
	import com.mixpanel.Mixpanel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import mx.utils.UIDUtil;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	public class MixpanelTest
	{
		private var mixpanel:Mixpanel;
		private var localMix:Mixpanel;
		private var asyncDispatcher:EventDispatcher;
		private static var asyncIDCounter:int = 0;
		
		private function makeMP(token:String=null, config:Object=null):Mixpanel {
			if (!token) { token = UIDUtil.createUID(); }
			var mp:Mixpanel = new Mixpanel(token);
			if (config) { mp.setConfig(config); }
			return mp;
		}
		
		[Before]
		public function setUp():void
		{
			mixpanel = makeMP("4874fb5a6ac20d3c883349defcfb9c99", { test: 1 });
			localMix = makeMP();
			
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
		
		[Test(description="sets distinct_id if user doesn't have one")]
		public function sets_distinct_id():void {
			var data:Object,
				id:String = UIDUtil.createUID();
			
			data = localMix.track("test_distinct_id");
			Assert.assertTrue("track() should set distinct id if it doesn't exist", data.properties.hasOwnProperty('distinct_id'));
			
			localMix.identify(id);
			data = localMix.track("test_distinct_id");
			Assert.assertEquals("track() should not override an already set distinct id", data.properties["distinct_id"], id);
		}
		
		[Test(async, description="disable() disabled all tracking from firing")]
		public function disable_events_from_firing():void {
			localMix.disable();
			
			localMix.track("e_a", function(resp:String):void {
				Assert.assertEquals("track should return an error", resp, 0);
			});
			
			var mp:Mixpanel = makeMP();
			mp.disable(["event_a"]);
			mp.disable(["event_c"]);
			
			var asyncID:int = asyncHandler(function(resp:String):void {
				Assert.assertEquals("server returned success", resp, "1");
			});
			
			mp.track("event_a", function(resp:String):void {
				Assert.assertEquals("track should return an error", resp, 0);
			});
			mp.track("event_b", function(resp:String):void {
				start(asyncID, resp);
			});
			mp.track("event_c", function(resp:String):void {
				Assert.assertEquals("track should return an error", resp, 0);
			});
		}
		
		[Test(description="storage should upgrade")]
		public function storage_upgrade():void {
			var old:SharedObject = SharedObject.getLocal("mixpanel"),
				token:String = UIDUtil.createUID();
			
			old.data[token] = {"all": { "prop_1": "test" }, "events": { "prop_2": "test" }, "funnels": { "prop_3": "test" }};
			
			var mp:Mixpanel = makeMP(token);

			Assert.assertTrue("old data[all] was imported", mp.storage.has("prop_1"));
			Assert.assertTrue("old data[events] was imported", mp.storage.has("prop_2"));
			Assert.assertFalse("old data[funnels] was not imported", mp.storage.has("prop_3"));
			Assert.assertFalse("old data was deleted", old.data.hasOwnProperty(token));
		}
		
		[Test(description="mixpanel instances should load data from shared objects")]
		public function load_save_data():void {
			var token:String = UIDUtil.createUID(),
				mp:Mixpanel = makeMP(token),
				prop:String = UIDUtil.createUID();
			
			mp.register({ "test": prop });
			
			var mp2:Mixpanel = makeMP(token);
			Assert.assertEquals("library should load existing shared object", mp2.storage.get("test"), prop);
			
			var mp3:Mixpanel = makeMP();
			Assert.assertFalse("library should create new shared object", mp3.storage.has("test"));
		}
		
		[Test(description="track() super properties are included")]
		public function track_super_properties():void {
			var props = { 'a': 'b', 'c': 'd' };
			localMix.register(props);
			
			var data = localMix.track('test'),
				dp = data.properties;
			
			Assert.assertTrue("token included in properties", dp.hasOwnProperty("token"));
			Assert.assertTrue("time included in properties", dp.hasOwnProperty("time"));
			Assert.assertTrue("mp_lib included in properties", dp.hasOwnProperty("mp_lib"));
			Assert.assertEquals("super properties included properly", dp['a'], props['a']);
			Assert.assertEquals("super properties included properly", dp['c'], props['c']);
		}
	}
}










