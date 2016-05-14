package com.seiee.bullet.data
{
	import com.seiee.bullet.object.MessageBox;

	/**
	 * <b>BulletConfig Class</b>
	 * <br>The class is an object of all configurations.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2015/10/24
	 * <br>Created on: 2014/10/15
	 */
	public final class BulletConfig
	{
		/**
		 * The font of texts. English names only.
		 */		
		public var FONT_FAMILY:String = "SimHei, 黑体, SimSun";
		/**
		 * The url of external swf file which includes font class. 
		 */		
		public var EXTERNAL_FONT_URL:String = null;
		/**
		 * The class name of font class in the external swf file. 
		 */		
		public var EXTERNAL_FONT_CLASS:String = null;
		/**
		 * The size of texts.
		 */		
		public var FONT_SIZE:Number = 24;
		/**
		 * The size of manual bullet texts.
		 */		
		public var MANUAL_FONT_SIZE:Number = 24;
		/**
		 * The list of colors for random selection. 
		 */		
		public var COLOR_LIST:Vector.<uint> = Vector.<uint>([0xffffff]);
		/**
		 * The height of each bullet lane. The lanes will be automatically set according to the value.
		 */		
		public var LANE_HEIGHT:Number = 28;
		/**
		 * The top offset of bullet area.
		 */	
		public var LANE_TOP_OFFSET:Number = 0;
		/**
		 * The height of each manual bullet lane. The lanes will be automatically set according to the value.
		 */		
		public var MANUAL_LANE_HEIGHT:Number = 28;
		/**
		 * The number of manual lanes. 
		 */		
		public var MANUAL_LANE_NUM:int = 2;
		/**
		 * The height of the gap between normal lanes and manual lanes;
		 */		
		public var MANUAL_LANE_GAP:Number = 0;
		
		/**
		 * Time of a bullet.
		 */
		public var BULLET_TIME:Number = 10000;
		/**
		 * A const used to calculate the time a bullet will last.
		 * <br>
		 * <br>When the length of a text is longer than MIN_CALC_LEN, the time is calculated by this formula:
		 * <br>time = TIME_PER_CHAR × (POW_BASE ^ (textLength - MIN_CALC_LEN)) × textLength
		 * <br>
		 * <br>When the length of a text is not longer than MIN_CALC_LEN, the time is calculated by this formula:
		 * <br>time = TIME_PER_CHAR × MIN_CALC_LEN
		 */		
		public var TIME_PER_CHAR:Number = 600;
		/**
		 * A const used to judge what formula will be used to calculate the time a bullet will last.
		 * <br>
		 * <br>Generally speaking, if the length of a text is not longer than this value, the time of each character 
		 * doesn't vary.
		 * But if the length is longer than this value, the time of each character will be shorter.
		 */		
		public var MIN_CALC_LEN:Number = 10;
		/**
		 * A const used to calculate the time a bullet will last.
		 * <br>
		 * <br>When the length of a text is longer than MIN_CALC_LEN, the time is calculated by this formula:
		 * <br>time = TIME_PER_CHAR × (POW_BASE ^ (textLength - MIN_CALC_LEN)) × textLength
		 * <br>
		 * <br>When the length of a text is not longer than MIN_CALC_LEN, the time is calculated by this formula:
		 * <br>time = TIME_PER_CHAR × MIN_CALC_LEN
		 */		
		public var POW_BASE:Number = 0.963;
		
		/**
		 * The delay for a bullet to show since it has been received from a server.
		 */		
		public var SHOWING_OFFSET_TIME:Number = 100;
		
		/**
		 * The maximum weight of a bullet lane. The value is used to identify a lane which cannot push another bullet now.
		 */		
		public var MAX_WEIGHT:int = 999;
		/**
		 * The weight multiplier of indexes. The value is set to allow lanes of smaller indexes to have higher priority 
		 * of pushing new bullets.
		 * <br>
		 * <br>The formula of the lane weight calculation is:
		 * <br>weight = Σ(weightOfBullets) + index * INDEX_WEIGHT
		 * <br>A lane of a lower weight has the priority of pushing new bullets.
		 */		
		public var INDEX_WEIGHT:int = 6;
		/**
		 * Weight pushing method.
		 * <br>
		 * <br>0 for order.
		 * <br>1 for random.
		 */	
		public var PUSH_METHOD:int = 0;
		/**
		 * The additional percent added to the percent of the moving process of a bullet. 
		 * <br>The value is used to calculate the current weight of a bullet.
		 * <br>The range of the value is [0, 1). However, it is recommended that the value should not be bigger than 0.1.
		 * <br>
		 * <br>The formula of the bullet weight calculation is
		 * <br>weight = ceil(((x + textWidth) / stageWidth + BULLET_WAIT_PERCENT) × 100)
		 * <br>A lane of a lower weight has the priority of pushing new bullets.
		 */		
		public var BULLET_WAIT_PERCENT:Number = 0.08;
		
		/**
		 * The value is used to calculate the showing time of fixed bullets.
		 * time = (timeOfNormalBullet) * FIXED_TIME_MULTIPLIER 
		 */		
		public var FIXED_TIME_MULTIPLIER:Number = 0.25;
		
		/**
		 * The url on the server to get bullet data. The response should be JSON format. 
		 */		
		public var SERVER_URL:String = null;
		/**
		 * The url on the server to get special bullet data. The response should be JSON format. 
		 */	
		public var SERVER_MANUAL_URL:String = null;
		/**
		 * The authentication url on the server.
		 */		
		public var SERVER_AUTH_URL:String = null;
		/**
		 * The username needed to authenticate identity on the server. Only POST method allowed.
		 */		
		public var SERVER_AUTH_USERNAME:String = null;
		/**
		 * The password needed to authenticate identity on the server. Only POST method allowed.
		 */
		public var SERVER_AUTH_PASSWORD:String = null;
		/**
		 * The interval time between two connections to server.
		 */		
		public var SERVER_CONNECTION_INTERVAL:int = 100;
		/**
		 * The count of items to fetch on each request.
		 */
		public var SERVER_FETCH_COUNT:int = 1;
		/**
		 * The list of urls of background images.
		 */		
		public var BG_URL_LIST:Vector.<String> = new Vector.<String>();
		/**
		 * The value determines whether the FPS Sprite is visible.
		 * <br>You can also press S to show/hide FPS.
		 */	
		public var SHOW_FPS:Boolean = false;
		/**
		 * Whether the mouse is hidden when the fullscreen mode is on.
		 */		
		public var HIDE_MOUSE:Boolean = false;
		/**
		 * The mode of message showing. It should be one of the consts in MessageBox class. 
		 */		
		public var MSG_SHOW_MODE:int = MessageBox.SHOW_ALL;
		
		/**
		 * Local sharedobject name.
		 */
		public var SO_NAME:String = "seiee_bullet";
		
		public function BulletConfig() {}
		
		public function get useExternalFont():Boolean
		{
			return (EXTERNAL_FONT_URL != null && EXTERNAL_FONT_URL != "");
		}
		
		public function setConfig(xml:XML):void
		{
			if (xml == null)
				return;
			
			try
			{
				if (xml.bullet.length() != 0)
				{
					FONT_FAMILY = xml.bullet.fontFamily;
					EXTERNAL_FONT_URL = xml.bullet.externalFontUrl;
					EXTERNAL_FONT_CLASS = xml.bullet.externalFontClass;
					FONT_SIZE = Number(xml.bullet.fontSize);
					MANUAL_FONT_SIZE = Number(xml.bullet.manualFontSize);
					COLOR_LIST = Vector.<uint>(xml.bullet.colorList.split(","));
					BULLET_TIME = Number(xml.bullet.bulletTime);
					TIME_PER_CHAR = Number(xml.bullet.timePerChar);
					MIN_CALC_LEN = Number(xml.bullet.minCalcLen);
					POW_BASE = Number(xml.bullet.powBase);
					SHOWING_OFFSET_TIME = Number(xml.bullet.showingOffsetTime);
					BULLET_WAIT_PERCENT = Number(xml.bullet.bulletWaitPercent);
					FIXED_TIME_MULTIPLIER = Number(xml.bullet.fixedTimeMultiplier);
				}
				
				if (xml.lane.length() != 0)
				{
					LANE_HEIGHT = Number(xml.lane.laneHeight);
					LANE_TOP_OFFSET = Number(xml.lane.laneTopOffset);
					MANUAL_LANE_HEIGHT = Number(xml.lane.manualLaneHeight);
					MAX_WEIGHT = int(xml.lane.maxWeight);
					INDEX_WEIGHT = int(xml.lane.indexWeight);
					MANUAL_LANE_NUM = int(xml.lane.manualLaneNum);
					MANUAL_LANE_GAP = Number(xml.lane.manualLaneGap);
					PUSH_METHOD = int(xml.lane.pushMethod);
				}
				
				if (xml.system.length() != 0)
				{
					SHOW_FPS = Boolean(int(xml.system.showFPS));
					HIDE_MOUSE = Boolean(int(xml.system.hideMouse));
					SERVER_CONNECTION_INTERVAL = int(xml.system.serverConnectionInterval);
					SERVER_URL = xml.system.serverUrl;
					SERVER_MANUAL_URL = xml.system.serverManualUrl;
					SERVER_AUTH_URL = xml.system.serverAuthUrl;
					SERVER_AUTH_USERNAME = xml.system.serverAuthUsername;
					SERVER_AUTH_PASSWORD = xml.system.serverAuthPassword;
					SERVER_FETCH_COUNT = int(xml.system.serverFetchCount);
					BG_URL_LIST = Vector.<String>(xml.system.bgUrlList.split(","));
					MSG_SHOW_MODE = int(xml.system.msgShowMode);
					SO_NAME = xml.system.soName;
				}
			}
			catch (e:Error) 
			{
				Global.message.pushMsg("配置读取失败！");
			}
		}
	}
}