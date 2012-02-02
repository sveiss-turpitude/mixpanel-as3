package com.mixpanel
{
	import com.mixpanel.Storage;
	import com.mixpanel.Util;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class Mixpanel
	{
		private var _:Util;
		private var config:Object;
		private var token:String;
		private var storage:Storage;
		private var disableAllEvents:Boolean = false;
		private var disabledEvents:Array = [];
		
		private var defaultConfig:Object = {
			crossSubdomainStorage: true,
			test: false
		};
		
		public function Mixpanel(token:String)
		{
			_ = new Util();
			token = token;
			var protocol:String = _.browserProtocol();
			
			config = _.extend({}, defaultConfig, {
				apiHost: protocol + '//api.mixpanel.com/track/',
				storageName: "mixpanel_" + token,
				token: token
			});
			
			storage = new Storage(config);
		}
		
		private function sendRequest(data:*, callback:Function=null):void {			
			var request:URLRequest = new URLRequest(config.apiHost);
			request.method = URLRequestMethod.GET;
			var params:URLVariables = new URLVariables();
			
			params = _.extend(params, data, {
				_: new Date().time.toString()
			});
			if (config["test"]) { params["test"] = 1; }
			
			request.data = params;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE,
				function(e:Event):void {
					if(callback != null) {
						callback(loader.data);
					}
				});
			
			loader.load(request);
		}
		
		public function track(event:String, properties:Object = null, callback:Function = null):Object
		{
			if (disableAllEvents || disabledEvents.indexOf(event) != -1) {
				return callback(0);
			}
		
			if (!properties) { properties = {}; }
			if (!properties["token"]) { properties.token = config.token; }
			properties["time"] = _.getUnixTime();
			properties["mp_lib"] = "as3";
			
			properties = storage.safeMerge(properties);
			
			var data:Object = {
				"event": event,
				"properties": properties
			};
			
			var truncatedData:Object = _.truncate(data, 255),
				jsonData:String = _.jsonEncode(truncatedData),
				encodedData:String = _.base64Encode(jsonData);
			
			sendRequest(
				{
					"data": encodedData,
					"ip": 1
				},
				callback
			);
			
			return truncatedData;
		}
		
		public function disable(events:Array = null):void
		{
						
		}
		
		public function register(properties:Object):void
		{
			
		}
		
		public function registerOnce(properties:Object, default_val:* = null):void
		{
			
		}
		
		public function unregister(property:String):void
		{
			
		}
		
		public function identify(uniqueID:String):void
		{
			
		}
		
		public function nameTag(name:String):void
		{
			
		}
		
		public function setConfig(config:Object):void
		{
			// TOOD: check cross_domain and update cookie if it changes			
		}
	}
}