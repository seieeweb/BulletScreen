package com.seiee.bullet.net
{
	import com.seiee.bullet.data.BulletData;
	import com.seiee.bullet.data.BulletManager;
	import com.seiee.bullet.data.BulletPosition;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.utils.Timer;

	/**
	 * <b>ServerConnection Class</b>
	 * <br>The class is an adapter for data tranmission from server.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2015/10/24
	 * <br>Created on: 2014/10/16
	 */
	public final class ServerConnection
	{
		private static const RETRY_COUNT:int = 30;
		/**
		 * The url of the server to get bullet data. The format is JSON.
		 */		
		private var serverUrl:String;
		/**
		 * The auth url of the server to confirm the identity. Only POST method is supported.
		 * <br>If the variable is null, no auth process will start.
		 */		
		private var serverAuthUrl:String;
		/**
		 * The username needed for authentication.
		 */		
		private var authUsername:String;
		/**
		 * The password needed for authentication.
		 */		
		private var authPassword:String;
		/**
		 * The url of the server to get manual action. The format is JSON.
		 */	
		private var serverManualUrl:String;
		/**
		 * The timer to control the interval of connect the server. 
		 */		
		private var timer:Timer;
		/**
		 * The BulletManager bound to push bullets. 
		 */		
		private var bulletManager:BulletManager;
		/**
		 * The id no to avoid repeat bullets; 
		 */		
		private var lastId:int = 0;
		/**
		 * The times left to retry connecting. 
		 */		
		private var retryCount:int = 0;
		/**
		 * The boolean to mark the status of identity on the server. Set for authentication. 
		 */		
		private var identityValid:Boolean;
		/**
		 * A flag marking whether the auth process is on. 
		 */		
		private var authProcessing:Boolean;
		/**
		 * A flag marking whether the validation can start.
		 */		
		private var needValidate:Boolean;
		/**
		 * Local data saver.
		 */
		private var sharedObject:SharedObject;
		
		/**
		 * The initialzing function. 
		 * @param bulletManager The manager object to push bullets.
		 * @param serverUrl The url of the server to get bullet data. The format is JSON.
		 * @param serverAuthUrl The auth url of the server. If the value is null, no auth process will start.
		 * @param authUsername The username needed for authentication.
		 * @param authPassword The username needed for authentication.
		 * 
		 */		
		public function ServerConnection(bulletManager:BulletManager, serverUrl:String, serverManualUrl:String, serverAuthUrl:String = null, authUsername:String = null, authPassword:String = null)
		{
			if (bulletManager == null)
				throw new ArgumentError("bulletManager is null");
			
			if (serverUrl == null || serverUrl == "")
				throw new ArgumentError("serverUrl is null");
			
			if (serverManualUrl == null || serverManualUrl == "")
				throw new ArgumentError("serverManualUrl is null");
			
			this.serverUrl = serverUrl;
			this.serverManualUrl = serverManualUrl;
			this.serverAuthUrl = serverAuthUrl;
			this.authUsername = authUsername;
			this.authPassword = authPassword;
			this.bulletManager = bulletManager;
			
			this.identityValid = (serverAuthUrl == null || serverAuthUrl == "");
			this.authProcessing = false;
			this.needValidate = false;
			
			this.sharedObject = SharedObject.getLocal(Global.config.SO_NAME, '/');
			initLastId();
		}
		
		/**
		 * Init last id data from local.
		 */
		private function initLastId():void
		{
			if (!sharedObject.data.hasOwnProperty('lastId') || 
				sharedObject.data['serverUrl'] != this.serverUrl)
			{
				sharedObject.data['lastId'] = 0;
				sharedObject.data['serverUrl'] = this.serverUrl;
			}
			sharedObject.flush();
			
			this.lastId = int(sharedObject.data['lastId']);
		}
		
		/**
		 * Start connecting the server at the interval given. 
		 * @param interval the interval between two connections
		 * 
		 */		
		public function startConnection(interval:int = 0):void
		{
			if (interval <= 0)
				interval = Global.config.SERVER_CONNECTION_INTERVAL;
			
			if (timer != null)
				return;
			
			timer = new Timer(interval);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
		}
		
		/**
		 * Stop connecting the server. 
		 * @return Whether the action succeeds.
		 * 
		 */		
		public function stopConnection():Boolean
		{
			if (timer == null)
				return false;
			
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, timerHandler);
			timer = null;
			
			return true;
		}
		
		private function postIdentity():void
		{
			if (serverAuthUrl == null || serverAuthUrl == "" || authProcessing)
				return;
			
			authProcessing = true;
			identityValid = false;
			needValidate = false;
			
			connectAuthServer();
		}
		
		/**
		 * Loading JSON String and push it to bullet manager. 
		 * @param jsonStr the JSON String
		 * 
		 */		
		private function loadJSON(jsonStr:String):void
		{
			if (jsonStr == null || jsonStr == "")
				return;
			
			if (serverAuthUrl != null && serverAuthUrl != "" && jsonStr.charAt(0) == "<")
			{
				if (needValidate)
				{
					Global.message.pushMsg("身份验证失败！即将重试...");
					retryCount = RETRY_COUNT;
					needValidate = false;
				}
				else
				{
					Global.message.pushMsg("身份验证过期或格式错误！即将重试...");
					identityValid = false;
				}
				
				return;
			}
			
			try
			{
				loadJSON2(jsonStr);
			}
			catch (e:Error) {
				Global.message.pushMsg("服务器弹幕解析失败！即将重试...");
				retryCount = RETRY_COUNT;
			}
		}
		
		/**
		 * The internal function of loadJSON().
		 */		
		private function loadJSON2(jsonStr:String):void
		{
			var object:Object = JSON.parse(jsonStr) as Object;
			
			if (needValidate)
			{
				needValidate = false;
				identityValid = true;
				Global.message.pushMsg("身份验证成功！");
			}
			
			if (!object.hasOwnProperty('bullets'))
			{
				loadOldJSON(jsonStr);
				return;
			}
				
			var bullets:Array = object.bullets as Array;
			var postTimeList:Vector.<int> = new Vector.<int>();
			var len:int = bullets.length;
			var i:int = 0;
			
			for (i = 0; i < bullets.length; i++)
			{
				postTimeList.push(int(Math.random() * Global.config.SERVER_CONNECTION_INTERVAL));
			}
			postTimeList.sort(0);
			
			for (i = 0; i < bullets.length; i++)
			{
				var item:Object = bullets[i] as Object;
				
				// check repetition id
				var sourceId:int = int(item["source_id"]);
				var bufferId:int = int(item["id"]);
				if (bufferId == lastId)
					return;
				
				lastId = bufferId;
				var postTime:Date = new Date(new Date().getTime() + postTimeList[i]);
				
				// decode HTML tags
				var contentStr:String = decodeHTMLChars(item["content"].toString());
				var data:BulletData = new BulletData(postTime, contentStr);
				bulletManager.push(data);
				
				updateLastId();
			}
		}
		
		private function loadOldJSON(jsonStr:String):void
		{
			var object:Object = JSON.parse(jsonStr) as Object;
			
//			if (needValidate)
//			{
//				needValidate = false;
//				identityValid = true;
//				Global.message.pushMsg("身份验证成功！");
//			}
			
			if (!object.hasOwnProperty("content"))
				return;
			
			if (!object.hasOwnProperty("empty"))
				return;
			
			if (!object.hasOwnProperty("source_id"))
				return;
			
			if (object.empty)
				return;
			
			// check repetition id
			var sourceId:int = int(object["source_id"]);
			if (sourceId == lastId)
				return;
			
			lastId = sourceId;
			var postTime:Date = new Date();
			// decode HTML tags
			var contentStr:String = decodeHTMLChars(object["content"].toString());
			var data:BulletData = new BulletData(postTime, contentStr);
			bulletManager.push(data);
			
			updateLastId();
		}
		
		/**
		 * Update last id in local.
		 */
		private function updateLastId():void
		{
			sharedObject.data['lastId'] = lastId;
		}
		
		/**
		 * Loading JSON String and push it to manual lane controller.
		 * @param jsonStr the JSON String
		 * 
		 */		
		private function loadManualJSON(jsonStr:String):void
		{
			if (jsonStr == null || jsonStr == "")
				return;
			
			if (jsonStr.charAt(0) == "<")
			{
				Global.message.pushMsg("身份验证过期或格式错误！即将重试...");
				identityValid = false;
				
				return;
			}
			
			try
			{
				loadManualJSON2(jsonStr);
			}
			catch (e:Error) {
				Global.message.pushMsg("服务器弹幕解析失败！即将重试...");
				retryCount = RETRY_COUNT;
			}
		}
		
		/**
		 * The internal function of loadManualJSON().
		 */		
		private function loadManualJSON2(jsonStr:String):void
		{
			var array:Array = JSON.parse(jsonStr) as Array;
			
			for each (var object:Object in array)
			{
				if (!object.hasOwnProperty("content"))
					return;
				
				if (!object.hasOwnProperty("index"))
					return;
				
				var postTime:Date = new Date();
				var index:int = Global.config.MANUAL_LANE_NUM - 1 - uint(object["index"].toString());
				
				if (index >= Global.config.MANUAL_LANE_NUM)
					return;
				
				// decode HTML tags
				var contentStr:String = decodeHTMLChars(object["content"].toString());
				var data:BulletData = new BulletData(postTime, contentStr, null, BulletPosition.MANUAL, 0, index);
				bulletManager.push(data);
			}
		}
		
		/**
		 * The internal function of connecting server.
		 * Note: The function has no status check beforing connecting.
		 */		
		private function connectServer():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, connectionFailedHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, connectionFailedHandler);
			loader.addEventListener(Event.COMPLETE, connectionSuccessHandler);
			try
			{
				loader.load(new URLRequest(serverUrl + "?limit=" + Global.config.SERVER_FETCH_COUNT + "&from=" + lastId + "&random=" + Math.random()));
			}
			catch (e:Error)
			{
				Global.message.pushMsg("服务器连接失败！即将重试...");
				retryCount = RETRY_COUNT;
			}
		}
		
		/**
		 * The internal function of connecting auth server.
		 * Note: The function has no status check beforing connecting.
		 */		
		private function connectAuthServer():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, authFailedHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, authFailedHandler);
			loader.addEventListener(Event.COMPLETE, authSuccessHandler);
			try
			{
				var variables:URLVariables = new URLVariables();
				variables.username = authUsername;
				variables.password = authPassword;
				
				var request:URLRequest = new URLRequest(serverAuthUrl);
				request.method = URLRequestMethod.POST;
				request.data = variables;
				loader.load(request);
			}
			catch (e:Error)
			{
				Global.message.pushMsg("身份验证连接失败！即将重试...");
				authProcessing = false;
				retryCount = RETRY_COUNT;
			}
		}
		
		/**
		 * The internal function of connecting manual server.
		 * Note: The function has no status check beforing connecting.
		 */		
		private function connectManualServer():void
		{
			var manualLoader:URLLoader = new URLLoader();
			manualLoader.addEventListener(IOErrorEvent.IO_ERROR, manualFailedHandler);
			manualLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, manualFailedHandler);
			manualLoader.addEventListener(Event.COMPLETE, manualSuccessHandler);
			try
			{
				manualLoader.load(new URLRequest(serverManualUrl + "?random=" + Math.random()));
			}
			catch (e:Error)
			{
				Global.message.pushMsg("服务器连接失败！即将重试...");
				retryCount = RETRY_COUNT;
			}
		}
		
		/**
		 * Decode special chars encoded by htmlspecialchars() function in php 
		 * @param contentStr the string needing decoding
		 * @return the string decoded
		 * 
		 */		
		private function decodeHTMLChars(contentStr:String):String
		{
			var result:String = contentStr;
			result = result.replace(/&quot;/g, "\"");
			result = result.replace(/&apos;/g, "'");
			result = result.replace(/&#039;/g, "'");
			result = result.replace(/&lt;/g, "<");
			result = result.replace(/&gt;/g, ">");
			result = result.replace(/&amp;/g, "&");
			return result;
		}
		
		/**
		 * Handler for TimerEvent. 
		 * 
		 */		
		private function timerHandler(event:TimerEvent):void
		{
			if (retryCount > 0)
			{
				retryCount--;
				return;
			}
			else if (!identityValid && !needValidate)
			{
				if (!authProcessing)
					postIdentity();
				return;
			}
			
			System.useCodePage = true;
			connectServer();
			if (identityValid)
				connectManualServer();
		}
		
		/**
		 * Success Handler. 
		 * 
		 */
		private function connectionSuccessHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var jsonStr:String = loader.data;
			loadJSON(jsonStr);
			
			loader.removeEventListener(IOErrorEvent.IO_ERROR, connectionFailedHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, connectionFailedHandler);
			loader.removeEventListener(Event.COMPLETE, connectionSuccessHandler);
		}
		
		/**
		 * Fail handler. 
		 * 
		 */		
		private function connectionFailedHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			Global.message.pushMsg("服务器连接失败！即将重试...");
			retryCount = RETRY_COUNT;
			
			loader.removeEventListener(IOErrorEvent.IO_ERROR, connectionFailedHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, connectionFailedHandler);
			loader.removeEventListener(Event.COMPLETE, connectionSuccessHandler);
		}
		
		/**
		 * Success Handler. 
		 * 
		 */
		private function manualSuccessHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var jsonStr:String = loader.data;
			loadManualJSON(jsonStr);
			
			loader.removeEventListener(IOErrorEvent.IO_ERROR, connectionFailedHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, connectionFailedHandler);
			loader.removeEventListener(Event.COMPLETE, connectionSuccessHandler);
		}
		
		/**
		 * Fail handler. 
		 * 
		 */		
		private function manualFailedHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			Global.message.pushMsg("服务器连接失败！即将重试...");
			retryCount = RETRY_COUNT;
			
			loader.removeEventListener(IOErrorEvent.IO_ERROR, connectionFailedHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, connectionFailedHandler);
			loader.removeEventListener(Event.COMPLETE, connectionSuccessHandler);
		}
		
		/**
		 * Auth Success Handler. 
		 * 
		 */
		private function authSuccessHandler(event:Event):void
		{
			if (identityValid)
				return;
			
			var loader:URLLoader = event.target as URLLoader;
			authProcessing = false;
			if ((loader.data as String).charAt(0) != "<")
			{
				loadJSON(loader.data);
			}
			else
			{
				needValidate = true;
			}
			
			loader.removeEventListener(IOErrorEvent.IO_ERROR, authFailedHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, authFailedHandler);
			loader.removeEventListener(Event.COMPLETE, authSuccessHandler);
		}
		
		/**
		 * Auth Fail handler. 
		 * 
		 */		
		private function authFailedHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			Global.message.pushMsg("身份验证服务器连接失败！即将重试...");
			authProcessing = false;
			retryCount = RETRY_COUNT;
			
			loader.removeEventListener(IOErrorEvent.IO_ERROR, authFailedHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, authFailedHandler);
			loader.removeEventListener(Event.COMPLETE, authSuccessHandler);
		}

	}
}