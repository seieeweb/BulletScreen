package com.seiee.bullet.scene
{
	import com.seiee.bullet.controller.ManualBulletController;
	import com.seiee.bullet.data.BulletConfig;
	import com.seiee.bullet.data.BulletData;
	import com.seiee.bullet.data.BulletManager;
	import com.seiee.bullet.data.BulletPosition;
	import com.seiee.bullet.net.ExternalFontLoader;
	import com.seiee.bullet.net.ServerConnection;
	import com.seiee.bullet.object.Background;
	import com.seiee.bullet.object.Bullet;
	import com.seiee.bullet.object.BulletLane;
	import com.seiee.bullet.object.FPSShow;
	import com.seiee.bullet.object.FixedBulletLane;
	import com.seiee.bullet.object.ManualBulletLane;
	import com.seiee.bullet.object.MessageBox;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.setTimeout;
	
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#000000")]
	/**
	 * <b>BulletScreen Class</b>
	 * <br>The class is the main scene of the program and work as a controller.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2015/10/19
	 * <br>Created on: 2014/10/8
	 */
	public class BulletScreen extends Sprite
	{
		/**
		 * The background of the scene. 
		 */		
		public var bg:Background;
		/**
		 * The external font loader; 
		 */		
		public var fontLoader:ExternalFontLoader;
		/**
		 * The list of lanes on the screen. 
		 */		
		public var laneList:Vector.<BulletLane>;
		/**
		 * The list of top fixed lanes on the screen. 
		 */	
		public var topLaneList:Vector.<BulletLane>;
		/**
		 * The list of bottom fixed lanes on the screen. 
		 */	
		public var bottomLaneList:Vector.<BulletLane>;
		/**
		 * The list of manual lanes on the screen. 
		 */
		public var manualLaneList:Vector.<ManualBulletLane>;
		
		/**
		 * The FPS Sprite. 
		 */		
		private var fpsSprite:FPSShow;
		
		/**
		 * The initialzing function of the class. 
		 * 
		 */		
		public function BulletScreen()
		{
			super();
			init();
		}
		
		/**
		 * Internal initialzing function.
		 * 
		 */		
		private function init():void
		{
			Global.config = new BulletConfig();
			Global.stage = stage;
			Global.message = new MessageBox();
			addChild(Global.message);
			Global.scene = this;
			if (Capabilities.playerType == "Desktop") {
				Global.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				
				var window:NativeWindow = Global.stage.nativeWindow;
				window.alwaysInFront = true;
			} else {
				var menu:ContextMenu = new ContextMenu();
				menu.hideBuiltInItems();
				menu.customItems = [
					new ContextMenuItem(Global.PRODUCT + " " + Global.VERSION, true, false),
					new ContextMenuItem(Global.COPYRIGHT, false, false)
				];
				
				this.contextMenu = menu;
			}
			
			loadConfigFile();
		}
		
		/**
		 * Font initialzing function.
		 * 
		 */
		private function initFont():void
		{
			fontLoader = new ExternalFontLoader();
			fontLoader.addEventListener(Event.COMPLETE, fontLoadingSuccessHandler);
			fontLoader.addEventListener(ErrorEvent.ERROR, fontLoadingFailedHandler);
			fontLoader.loadFont(Global.config.EXTERNAL_FONT_URL, Global.config.EXTERNAL_FONT_CLASS);
		}
		
		/**
		 * Scene initialzing function.
		 * 
		 */		
		private function initScene():void
		{
			
			createBg();
			createLanes();
			createFPSSprite();
			
			new ExternalFontLoader();
			
			var serverUrl:String = (stage.loaderInfo.parameters.hasOwnProperty("serverUrl")) ?
				stage.loaderInfo.parameters["serverUrl"] : Global.config.SERVER_URL;
			var serverManualUrl:String = (stage.loaderInfo.parameters.hasOwnProperty("serverManualUrl")) ?
				stage.loaderInfo.parameters["serverManualUrl"] : Global.config.SERVER_MANUAL_URL;
			Global.bulletManager = new BulletManager();
			Global.server = new ServerConnection(Global.bulletManager, serverUrl, serverManualUrl,
												Global.config.SERVER_AUTH_URL, Global.config.SERVER_AUTH_USERNAME, 
												Global.config.SERVER_AUTH_PASSWORD);
			
			// The following code is just for testing
			/*flash.utils.setTimeout(function ():void {
			var dat:BulletData = new BulletData(new Date(new Date().time), "我是第二只小弹幕！我就是很长你信不信不信不信不信不信不信不信不信不信不信不信不信不信不信不信不信不信不信不信不信不信不信=3=");
			Global.bulletManager.push(dat);
			}, 3500);
			
			var dat:BulletData = new BulletData(new Date(new Date().time + 1000), "我是一只小弹幕！=3=");
			Global.bulletManager.push(dat);
			
			dat = new BulletData(new Date(new Date().time + 1000), "我是顶部小弹幕！=3=", null, BulletPosition.TOP);
			Global.bulletManager.push(dat);
			
			dat = new BulletData(new Date(new Date().time + 1000), "我是底部小弹幕！=3=", null, BulletPosition.BOTTOM);
			Global.bulletManager.push(dat);
			
			for (var i:int = 0; i < 100; i++)
			{
				dat = dat.clone();
				dat.position = 0;
				dat.text = "Bullet Test" + i;
				Global.bulletManager.push(dat);
			}*/
			
			addListeners();
			Global.server.startConnection();
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		}
		
		/**
		 * Setup Listeners. 
		 * 
		 */		
		private function addListeners():void
		{
			stage.addEventListener(Event.ENTER_FRAME, updateHandler);
			stage.addEventListener(Event.RESIZE, resizeHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		/**
		 * Create background. 
		 * 
		 */		
		private function createBg():void
		{
			bg = new Background();
			addChild(bg);
			swapChildren(bg, Global.message);
		}
		
		/**
		 * Create lanes. 
		 * 
		 */		
		private function createLanes():void
		{
			laneList = new Vector.<BulletLane>();
			topLaneList = new Vector.<BulletLane>();
			bottomLaneList = new Vector.<BulletLane>();
			manualLaneList = new Vector.<ManualBulletLane>();
			
			var laneNum:int = int((stage.stageHeight - Global.config.MANUAL_LANE_GAP - Global.config.LANE_TOP_OFFSET - 
								Global.config.MANUAL_LANE_NUM * ManualBulletLane.manualLaneHeight) / BulletLane.laneHeight);
			for (var i:int = 0; i < laneNum; i++)
			{
				var lane:BulletLane = new BulletLane(i);
				laneList.push(lane);
				addChild(lane);
				
				var topLane:BulletLane = new FixedBulletLane(i, BulletPosition.TOP);
				topLaneList.push(topLane);
				addChild(topLane);
				
				var bottomLane:BulletLane = new FixedBulletLane(i, BulletPosition.BOTTOM);
				bottomLaneList.push(bottomLane);
				addChild(bottomLane);
			}
			
			for (i = 0; i < Global.config.MANUAL_LANE_NUM; i++)
			{
				var manualLane:ManualBulletLane = new ManualBulletLane(i);
				manualLaneList.push(manualLane);
				addChild(manualLane);
			}
			
			Global.manualController = new ManualBulletController(manualLaneList);
		}
		
		/**
		 * Create FPS Sprite. 
		 * 
		 */		
		private function createFPSSprite():void
		{
			fpsSprite = new FPSShow();
			fpsSprite.visible = Global.config.SHOW_FPS;
			addChild(fpsSprite);
		}
		
		/**
		 * Loading config file. 
		 * 
		 */		
		private function loadConfigFile():void
		{
			var loader:URLLoader = new URLLoader();
			var url:String = (stage.loaderInfo.parameters.hasOwnProperty("config")) ?
				stage.loaderInfo.parameters["config"] : "config.xml";
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadingFailedHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadingFailedHandler);
			loader.addEventListener(Event.COMPLETE, loadingSuccessHandler);
			try
			{
				loader.load(new URLRequest(url));
			}
			catch (e:Error)
			{
				Global.message.pushMsg("加载配置失败！");
				Global.message.update(new Date());
			}
		}
		
		/**
		 * Getting the count of bottom fixed lanes.
		 * 
		 */		
		public function get bottomLaneCount():uint
		{
			return laneList.length;
		}
		
		/**
		 * Key Handler. 
		 * @param event
		 * 
		 */		
		private function keyUpHandler(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				// Press F to enter Fullscreen mode (Press Esc to exit mode)
				case 70:
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					break;
				// Press S to show/hide FPS
				case 83:
					fpsSprite.visible = (!fpsSprite.visible);
					break;
				// Press Up/Left Key to show the previous image.
				case Keyboard.UP:
				case Keyboard.LEFT:
					bg.prevImage();
					break;
				// Press Down/Right Key to show the previous image.
				case Keyboard.DOWN:
				case Keyboard.RIGHT:
					bg.nextImage();
					break;
				default:
					return;
					break;
			}
			event.updateAfterEvent();
		}
		
		/**
		 * Loading Fail Handler. 
		 * @param event
		 * 
		 */		
		private function loadingFailedHandler(event:Event):void
		{
			Global.message.pushMsg("加载配置失败！");
			initScene();
		}
		
		/**
		 * Loading Success Handler. 
		 * @param event
		 * 
		 */		
		private function loadingSuccessHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			try {
				var data:XML = XML(loader.data);
				Global.config.setConfig(data);
			}
			catch (e:Error) {}
			
			Global.message.pushMsg("加载配置成功！");
			if (Global.config.useExternalFont)
				initFont();
			else
				initScene();
		}
		
		/**
		 * Font Loading Fail Handler. 
		 * @param event
		 * 
		 */		
		private function fontLoadingFailedHandler(event:Event):void
		{
			fontLoader.removeEventListener(Event.COMPLETE, fontLoadingSuccessHandler);
			fontLoader.removeEventListener(ErrorEvent.ERROR, fontLoadingFailedHandler);
			Global.message.pushMsg("加载字体失败！");
			Global.config.EXTERNAL_FONT_URL = null;		// use system fonts
			initScene();
		}
		
		/**
		 * Font Loading Success Handler. 
		 * @param event
		 * 
		 */		
		private function fontLoadingSuccessHandler(event:Event):void
		{
			fontLoader.removeEventListener(Event.COMPLETE, fontLoadingSuccessHandler);
			fontLoader.removeEventListener(ErrorEvent.ERROR, fontLoadingFailedHandler);
			Global.message.pushMsg("加载字体成功！");
			initScene();
		}
		
		/**
		 * Resize Handler. 
		 * @param event
		 * 
		 */		
		private function resizeHandler(event:Event):void
		{
			var laneNum:int = int((stage.stageHeight - Global.config.MANUAL_LANE_GAP - Global.config.LANE_TOP_OFFSET -
				Global.config.MANUAL_LANE_NUM * ManualBulletLane.manualLaneHeight) / BulletLane.laneHeight);
			
			var lane:BulletLane;
			var topLane:FixedBulletLane;
			var bottomLane:FixedBulletLane;
			
			if (laneNum > laneList.length)
			{
				while (laneList.length < laneNum)
				{
					lane = new BulletLane(laneList.length);
					laneList.push(lane);
					addChild(lane);
					
					topLane = new FixedBulletLane(topLaneList.length, BulletPosition.TOP);
					topLaneList.push(topLane);
					addChild(topLane);
					
					bottomLane = new FixedBulletLane(bottomLaneList.length, BulletPosition.BOTTOM);
					bottomLaneList.push(bottomLane);
					addChild(bottomLane);
				}
			}
			
			for (var i:int = 0; i < laneList.length; i++)
			{
				lane = laneList[i] as BulletLane;
				lane.hidden = (i >= laneNum);
				lane.visible = (!lane.hidden);
				
				topLane = topLaneList[i] as FixedBulletLane;
				topLane.hidden = (i >= laneNum);
				topLane.visible = (!topLane.hidden);
				topLane.updatePosition();
				
				bottomLane = bottomLaneList[i] as FixedBulletLane;
				bottomLane.hidden = (i >= laneNum);
				bottomLane.visible = (!bottomLane.hidden);
				bottomLane.updatePosition();
			}
			
			bg.updatePosition();
			Global.manualController.updatePosition();
		}
		
		/**
		 * Update Handler.
		 * @param event
		 * 
		 */		
		private function updateHandler(event:Event):void
		{
			if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
				var window:NativeWindow = Global.stage.nativeWindow;
				window.orderToFront();
			}
			
			if (Global.config.HIDE_MOUSE)
			{
				if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
				{
					Mouse.hide();
				}
				else
				{
					Mouse.show();
				}
			}
			
			var currentTime:Date = new Date();
			for (var i:int = 0; i < 3; i++)
			{
				updateLaneList(currentTime, i);
			}
			
			bg.update(currentTime);
			Global.message.update(currentTime);
		}
		
		public function updateLaneList(currentTime:Date, position:int = BulletPosition.DEFAULT):void
		{
			var currentList:Vector.<BulletLane>;
			
			switch (position)
			{
				case BulletPosition.DEFAULT:
					currentList = laneList;
					break;
				case BulletPosition.TOP:
					currentList = topLaneList;
					break;
				case BulletPosition.BOTTOM:
					currentList = bottomLaneList;
					break;
			}
			
			for (var i:int = 0; i < currentList.length; i++)
			{
				if (position == BulletPosition.DEFAULT)
				{
					var lane:BulletLane = currentList[i] as BulletLane;
					lane.update(currentTime);
				}
				else
				{
					var fixedLane:FixedBulletLane = currentList[i] as FixedBulletLane;
					fixedLane.update(currentTime);
				}
			}
			pushNextBullet(currentTime, position);
		}
		
		/**
		 * Update next bullets. 
		 * 
		 */		
		private function pushNextBullet(currentTime:Date, position:int = BulletPosition.DEFAULT):void
		{
			var minWeight:int;
			var minIndex:int;
			var hasNext:Boolean;
			var currentList:Vector.<BulletLane>;
			
			switch (position)
			{
				case BulletPosition.DEFAULT:
					currentList = laneList;
					break;
				case BulletPosition.TOP:
					currentList = topLaneList;
					break;
				case BulletPosition.BOTTOM:
					currentList = bottomLaneList;
					break;
			}
			
			if (position == BulletPosition.DEFAULT && Global.config.PUSH_METHOD == 1)
			{
				// random push
				while (hasNext = Global.bulletManager.hasNext(currentTime, position))
				{
					var availableIndex:Vector.<int> = new Vector.<int>();
					
					for (var i:int = 0; i < currentList.length; i++)
					{
						var lane:BulletLane = currentList[i] as BulletLane;
						
						if (!lane.hidden && lane.canShowNext())
						{
							availableIndex.push(i);
						}
					}
					
					if (availableIndex.length == 0)
						break;
					
					var index:int = availableIndex[int(Math.random() * availableIndex.length)];
					var data:BulletData = Global.bulletManager.next(currentTime, position);
					(currentList[index] as BulletLane).pushBullet(data);
				}
			}
			else
			{
				// weight push
				while (hasNext = Global.bulletManager.hasNext(currentTime, position))
				{
					minWeight = Global.config.MAX_WEIGHT;
					minIndex = -1;
					
					for (var i2:int = 0; i2 < currentList.length; i2++)
					{
						var fixedLane:BulletLane = currentList[i2] as BulletLane;
						
						if (!fixedLane.hidden && fixedLane.canShowNext())
						{
							if (fixedLane.showWeight < minWeight)
							{
								minWeight = fixedLane.showWeight;
								minIndex = i2;
							}
						}
					}
					
					if (minIndex != -1)
					{
						var fixedData:BulletData = Global.bulletManager.next(currentTime, position);
						(currentList[minIndex] as BulletLane).pushBullet(fixedData);
					}
					else
					{
						break;
					}
				}
			}
		}
	}
}