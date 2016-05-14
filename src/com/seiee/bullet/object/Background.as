package com.seiee.bullet.object
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * <b>Background Class</b>
	 * <br>The class is an wrapper for background images.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2015/10/19
	 * <br>Created on: 2014/10/15
	 */
	public class Background extends Sprite implements IDisplayObject
	{
		/**
		 * The maximum frames of a transition. 
		 */		
		private static const MAX_TRANSITION_COUNT:int = 20;
		/**
		 * The snapshot bitmap for transition. 
		 */		
		private var lastSnap:Bitmap;
		/**
		 * The current bitmap. 
		 */		
		private var currentBg:Bitmap;
		/**
		 * The list of bg urls. 
		 */		
		private var urlList:Vector.<String>;
		/**
		 * The current index of the list. 
		 */		
		private var currentIndex:int;
		/**
		 * The common loader. 
		 */		
		private var loader:Loader;
		/**
		 * The width of the stage. Used to update positions. 
		 */		
		private var stageWidth:Number;
		/**
		 * The height of the stage. Used to update positions. 
		 */
		private var stageHeight:Number;
		/**
		 * Whether the bg is changing. No next/prev operation is available when changing. 
		 */		
		private var changing:Boolean = false;
		/**
		 * Whether the next bg or the previous bg is loading. 
		 */		
		private var loadingNext:Boolean = false;
		/**
		 * The current frames count of transition. 
		 */		
		private var transitionCount:int = 0;
		/**
		 * The cache of loaded bitmapData. Used to accelerate the changing process. 
		 */		
		private static var cacheBitmap:Dictionary = new Dictionary(true);
		
		/**
		 * The initialzing function. 
		 * 
		 */		
		public function Background()
		{
			super();
			
			lastSnap = null;
			currentBg = null;
			currentIndex = -1;
			urlList = Global.config.BG_URL_LIST;
			
			stageWidth = Global.stage.stageWidth;
			stageHeight = Global.stage.stageHeight;
			
			nextImage();
		}
		
		/**
		 * Change to the next image in the url list. 
		 * 
		 */		
		public function nextImage():void
		{
			if (urlList.length == 0 || changing || currentIndex + 1 == urlList.length)
				return;
			
			changing = true;
			loadingNext = true;
			var url:String = urlList[currentIndex+1];
			
			if (readImageFromCache(url))
			{
				return;
			}
			
			loadImage(url);
		}
		
		/**
		 * Change to the previous image in the url list. 
		 * 
		 */		
		public function prevImage():void
		{
			if (urlList.length == 0 || changing || currentIndex - 1 == -1)
				return;
			
			changing = true;
			loadingNext = false;
			var url:String = urlList[currentIndex-1];
			var request:URLRequest = new URLRequest(url);
			
			if (readImageFromCache(url))
			{
				return;
			}
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, successHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failHandler);
			
			try
			{
				loader.load(request);
			}
			catch (e:Error)
			{
				Global.message.pushMsg("加载背景失败！");
			}
		}
		
		/**
		 * The main process of loading image. This is an internal function.
		 * @param url The url of an image.
		 * 
		 */		
		private function loadImage(url:String):void
		{
			var request:URLRequest = new URLRequest(url);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, successHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failHandler);
			
			try
			{
				loader.load(request);
			}
			catch (e:Error)
			{
				Global.message.pushMsg("加载背景失败！");
			}
		}
		
		/**
		 * Start the transition of bg. 
		 * @param newBg the new bitmap
		 * 
		 */		
		private function transitBg(newBg:Bitmap):void
		{
			if (lastSnap != null)
			{
				removeChild(lastSnap);
				lastSnap = null;
			}
			
			// snapshot the current bg
			var snapData:BitmapData = new BitmapData(stageWidth, stageHeight, true, 0x00000000);
			if (currentBg != null)
			{
				var matrix:Matrix = new Matrix();
				matrix.scale(stageWidth / currentBg.bitmapData.width , stageHeight / currentBg.bitmapData.height);
				snapData.drawWithQuality(currentBg, matrix, null, null, null, true, StageQuality.HIGH);
				removeChild(currentBg);
				currentBg = null;
				
			}
			
			lastSnap = new Bitmap(snapData);
			currentBg = newBg;
			currentBg.alpha = 0;
			
			addChild(currentBg);
			addChild(lastSnap);
			
			transitionCount = MAX_TRANSITION_COUNT;
		}
		
		/**
		 * @inheritDoc
		 */		
		public function update(currentTime:Date):void
		{
			if (transitionCount != 0)
			{
				lastSnap.alpha = Math.sin(Math.PI / 2 * transitionCount / MAX_TRANSITION_COUNT);
				currentBg.alpha = Math.cos(Math.PI / 2 * transitionCount / MAX_TRANSITION_COUNT);
				transitionCount--;
				
				if (transitionCount == 0)
				{
					currentBg.alpha = 1;
					removeChild(lastSnap);
					lastSnap = null;
					changing = false;
					currentIndex += (loadingNext) ? 1 : -1;
					loadingNext = false;
				}
			}
		}
		
		/**
		 * Update the position when the stage is resized. 
		 * 
		 */		
		public function updatePosition():void
		{
			stageWidth = Global.stage.stageWidth;
			stageHeight = Global.stage.stageHeight;
			
			if (currentBg != null)
			{
				currentBg.width = stageWidth;
				currentBg.height = stageHeight;
			}
			
			if (lastSnap != null)
			{
				lastSnap.width = stageWidth;
				lastSnap.height = stageHeight;
			}
		}
		
		/**
		 * @inheritDoc 
		 * 
		 */		
		public function dispose():void
		{
			if (lastSnap != null)
			{
				removeChild(lastSnap);
				lastSnap = null;
			}
			
			if (currentBg != null)
			{
				removeChild(currentBg);
				currentBg = null;
			}
			
			if (loader != null)
			{
				loader = null;
			}
		}
		
		/**
		 * Reading bitmapData from cache. 
		 * @param url the url of an image.
		 * @return whether the reading process succeeds.
		 * 
		 */		
		private function readImageFromCache(url:String):Boolean
		{
			var data:BitmapData = null;
			for (var key:* in cacheBitmap)
			{
				if (!key is BitmapData)
					continue;
				
				if (cacheBitmap[key] == url)
				{
					data = key;
					break;
				}
			}
			
			if (data == null)
				return false;
			
			var nextBg:Bitmap = new Bitmap(data, PixelSnapping.ALWAYS, true);
			nextBg.width = stageWidth;
			nextBg.height = stageHeight;
			transitBg(nextBg);
			
			return true;
		}
		
		/**
		 * Loading success Handler. 
		 * 
		 */		
		private function successHandler(event:Event):void
		{
			var info:LoaderInfo = event.target as LoaderInfo;
			var nextBg:Bitmap = new Bitmap((info.content as Bitmap).bitmapData.clone(), PixelSnapping.ALWAYS, true);
			nextBg.width = stageWidth;
			nextBg.height = stageHeight;
			
			cacheBitmap[nextBg.bitmapData] = (loadingNext) ? urlList[currentIndex+1] : urlList[currentIndex-1];
			info.removeEventListener(Event.COMPLETE, successHandler);
			info.removeEventListener(IOErrorEvent.IO_ERROR, failHandler);
			(loader.content as Bitmap).bitmapData.dispose();
			loader.unload();
			
			transitBg(nextBg);
		}
		
		/**
		 * Loading fail Handler. 
		 * 
		 */		
		private function failHandler(event:Event):void
		{
			changing = false;
			loadingNext = false;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, successHandler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, failHandler);
			loader.unload();
			
			Global.message.pushMsg("加载背景失败！");
		}
	}
}