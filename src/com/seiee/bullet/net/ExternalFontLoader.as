package com.seiee.bullet.net
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.Font;
	import flash.utils.getDefinitionByName;

	/**
	 * <b>ExternalFontLoader Class</b>
	 * <br>The class is a controller to load external font resources.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/22
	 * <br>Created on: 2014/10/22
	 */
	public final class ExternalFontLoader extends EventDispatcher
	{
		/**
		 * The current loader.
		 */		
		private var fontLoader:Loader;
		/**
		 * The class name of the Font. 
		 */		
		private var className:String;
		
		/**
		 * Loading a font from an external file. 
		 * @param url the url of the external swf file
		 * @param className the class name of the font
		 * 
		 */		
		public function loadFont(url:String, className:String):void
		{
			this.fontLoader = new Loader();
			this.className = className;

			fontLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			fontLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failHandler);
			try
			{
				fontLoader.load(new URLRequest(url));
			}
			catch (e:Error)
			{
				dispatchErrorEvent();
			}
		}
		
		/**
		 * Dispatch an error event. 
		 * 
		 */		
		private function dispatchErrorEvent():void
		{
			this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}
		
		/**
		 * Dispatch a success event. 
		 * 
		 */		
		private function dispatchSuccessEvent():void
		{
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Complete Handler. 
		 * @param event
		 * 
		 */		
		private function completeHandler(event:Event):void
		{
			var applicationDomain:ApplicationDomain = (event.target as LoaderInfo).applicationDomain;
			if (!applicationDomain.hasDefinition("DefaultFont"))
			{
				dispatchErrorEvent();
				return;
			}
			
			var fontClass:Class = (event.target as LoaderInfo).applicationDomain.getDefinition("DefaultFont") as Class;
			try
			{
				Font.registerFont(fontClass);
			}
			catch (e:Error)
			{
				dispatchErrorEvent();
				return;
			}
			dispatchSuccessEvent();
		}
		
		/**
		 * Fail Handler. 
		 * @param event
		 * 
		 */		
		private function failHandler(event:Event):void
		{
			fontLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			fontLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, failHandler);
			dispatchErrorEvent();
		}
	}
}