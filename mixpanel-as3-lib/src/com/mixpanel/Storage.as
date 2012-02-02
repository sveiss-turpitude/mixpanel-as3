package com.mixpanel
{
	import flash.net.SharedObject;
	import flash.system.Security;

	internal class Storage
	{
		private var sharedObject:SharedObject;
		private var name:String;
		
		public function Storage(config:Object)
		{
			name = config.storageName;
			
			updateCrossDomain(config.crossSubdomainStorage);
			upgrade(config.token);
		}
		
		public function updateCrossDomain(crossDomainStorage:Boolean):void {
			try {
				Security.exactSettings = !crossDomainStorage;
			} catch(e:Error) {}
			
			sharedObject = load(name);
		}
		
		private function upgrade(token:String):void {
			var oldStorage:SharedObject = load("mixpanel");
			if (!oldStorage.data[token]) { return; }
			
			var oldData:Object = oldStorage.data[token];
			
			if (oldData["all"]) { register(oldData.all); }
			if (oldData["events"]) { register(oldData.events); }
			
			oldStorage.clear();
		}
		
		private function load(storageName:String):SharedObject {
			return SharedObject.getLocal(storageName);	
		}
		
		public function get(key:String):* {
			return sharedObject.data[key];
		}
		
		public function set(key:String, value:*):void {
			sharedObject.data[key] = value;
			sharedObject.flush();
		}
		
		public function register(obj:Object):void {
			for (var key:String in obj) {
				sharedObject.data[key] = obj[key];
			}
			sharedObject.flush();
		}
		
		public function registerOnce(obj:Object, defaultValue:* = "None"):void {
			for (var key:String in obj) {
				if (!sharedObject.data[key] || sharedObject.data[key] == defaultValue) {
					sharedObject.data[key] = obj[key];	
				}
			}
			sharedObject.flush();
		}
		
		public function unregister(property:String):void {
			delete sharedObject.data[property];
			sharedObject.flush();
		}
		
		public function safeMerge(properties:Object):Object {
			for (var key:String in sharedObject.data) {
				if (!properties[key]) { properties[key] = get(key); }
			}
			return properties;
		}
	}
}