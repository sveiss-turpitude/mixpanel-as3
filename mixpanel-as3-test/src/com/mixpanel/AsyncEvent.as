package com.mixpanel
{
	import flash.events.Event;
	
	public class AsyncEvent extends Event
	{
		public var args:Array;
		
		public function AsyncEvent(id:String, args:Array) {
			this.args = args;
			super(id, false, false);
		}
	}
}