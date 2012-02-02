package com.mixpanel
{
	import com.adobe.serialization.json.JSONEncoder;
	import com.mixpanel.Base64Encoder;
	
	import flash.external.ExternalInterface;

	internal class Util
	{
		private var base64Instance:Base64Encoder;
		
		public function Util()
		{
			base64Instance = new Base64Encoder();
		}
		
		public function getUnixTime():int {
			return parseInt(new Date().time.toString().substring(0, 10), 10);
		}
		
		public function jsonEncode(o:Object):String
		{
			return new JSONEncoder(o).getString();			
		}
		
		public function base64Encode(data:String):String
		{
			base64Instance.encode(data);
			return base64Instance.toString();
		}
		
		public function browserProtocol():String
		{
			var ret:String = "https:";
			if (ExternalInterface.available) {
				try {
					var extProtocol:String = ExternalInterface.call("document.location.protocol.toString");
					ret = (extProtocol && extProtocol.search("file") == -1) ? extProtocol : ret; 
				} catch (err:Error) {}
			}
			return ret;
		}
		
		public function extend(obj1:*, ...args):*
		{
			for (var i:String in args) {
				for (var param:String in args[i]) {
					obj1[param] = args[i][param];
				}
			}
			
			return obj1;
		}
		
		public function truncate(obj:*, length:int = 255):* {
			var ret:*;
			
			if (obj is String) {
				ret = (obj as String).slice(0, length);
			} else if (obj is Array) {
				ret = [];
				for (var val:* in obj) {
					ret.push(truncate(val, length));
				}
			} else if (obj is Object) {
				ret = {};
				for (var key:String in obj) {
					ret[key] = truncate(obj[key], length);
				}
			} else {
				ret = obj;
			}
			
			return ret;
		}
	}
}