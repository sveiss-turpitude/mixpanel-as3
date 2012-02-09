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
	
	import mx.utils.UIDUtil;
	
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
		
		
		/**
		 * Track an event.  This is the most important Mixpanel function and
		 * the one you will be using the most
		 *  
		 * @param event the name of the event
		 * @param args if the first arg in args is an object, it will be used
		 * as the properties object, the second arg is an optional callback function.
		 * The callback and properties arguments are both optional.
		 * @return the data sent to the server
		 * 
		 */
		public function track(event:String, ...args):Object
		{
			var properties:Object = null, callback:Function = null;
			
			if (args.length == 2) {
				properties = args[0];
				callback = args[1];
			} else {
				if (args[0] is Function) {
					callback = args[0];
				} else {
					properties = args[0];
				}
			}
			
			if (disableAllEvents || disabledEvents.indexOf(event) != -1) {
				if (callback != null) { return callback(0); }
			}
		
			if (!properties) { properties = {}; }
			if (!properties["token"]) { properties.token = config.token; }
			properties["time"] = _.getUnixTime();
			properties["mp_lib"] = "as3";
			
			this.registerOnce({ 'distinct_id': UIDUtil.createUID() }, "");
			
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
			if (events == null) {
				disableAllEvents = true;
			} else {
				disabledEvents = disabledEvents.concat(events);
			}
		}
		
		public function register(properties:Object):void
		{
			storage.register(properties);			
		}
		
		public function registerOnce(properties:Object, defaultValue:* = null):void
		{
			storage.registerOnce(properties, defaultValue);
		}
		
		public function unregister(property:String):void
		{
			storage.unregister(property);
		}
		
		public function identify(uniqueID:String):void
		{
			storage.register({ "distinct_id": uniqueID });
		}
		
		public function nameTag(name:String):void
		{
			storage.register({ "mp_name_tag": name });
		}
		
		public function setConfig(config:Object):void
		{
			if (config["crossSubdomainStorage"] && config.crossSubdomainStorage != this.config.crossSubdomainStorage) {
				storage.updateCrossDomain(config.crossSubdomainStorage);
			}
			_.extend(this.config, config);
		}
	}
}