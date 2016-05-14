package com.seiee.bullet.object
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * <b>MessageBox Class</b>
	 * <br>The class is a sprite showing all messages.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/18
	 * <br>Created on: 2014/10/18
	 */
	public class MessageBox extends Sprite implements IDisplayObject
	{
		/**
		 * This mode means all of the messages will be showed. 
		 */		
		public static const SHOW_ALL:int = 0;
		/**
		 * This mode means only fail messages will be showed. 
		 */		
		public static const SHOW_FAIL:int = 1;
		/**
		 * This mode means no messages will be showed. 
		 */		
		public static const SHOW_NONE:int = 2;
		/**
		 * The time for a single message to show. 
		 */		
		private static const SINGLE_MSG_TIME:Number = 1500;
		/**
		 * The message text field. 
		 */		
		private var msgText:TextField;
		/**
		 * The time at which the message will be hidden. 
		 */		
		private var hideTime:Date;
		/**
		 * The height of the screen. The variable is set to check resize changes. 
		 */		
		private var stageHeight:Number;
		/**
		 * The text ready to be appended to the textField; 
		 */		
		private var bufferingText:String;
		
		/**
		 * The initialzing function. 
		 * 
		 */		
		public function MessageBox()
		{
			super();
			init();
		}
		
		/**
		 * The internal initialzing function. 
		 * 
		 */		
		private function init():void
		{
			msgText = new TextField();
			msgText.selectable = false;
			msgText.autoSize = TextFieldAutoSize.LEFT;
			msgText.visible = false;
			
			var format:TextFormat = new TextFormat();
			format.font = Global.config.FONT_FAMILY;
			format.size = 14;
			format.color = 0xffffff;
			msgText.defaultTextFormat = format;
			
			hideTime = new Date();
			stageHeight = Global.stage.stageHeight;
			bufferingText = "";
			
			addChild(msgText);
		}
		
		/**
		 * Pushing a message into the box. 
		 * @param text message
		 * 
		 */		
		public function pushMsg(text:String):void
		{
			if (Global.config.MSG_SHOW_MODE == SHOW_NONE)
				return;
			
			if (Global.config.MSG_SHOW_MODE == SHOW_FAIL)
			{
				if (text.indexOf("失败") == -1 && text.indexOf("错误") == -1)
					return;
			}
			
			bufferingText += "\n" + text;
			hideTime = new Date(new Date().time + SINGLE_MSG_TIME);
		}
		
		/**
		 * Update the position of the text. 
		 * 
		 */		
		private function updatePosition():void
		{
			msgText.x = 0;
			msgText.y = stageHeight - msgText.height;
		}
		
		/**
		 * @inheritDoc
		 * 
		 */		
		public function update(currentTime:Date):void
		{
			if (bufferingText != "")
			{
				msgText.visible = true;
				msgText.appendText(bufferingText);
				updatePosition();
				bufferingText = "";
			}
			
			if (currentTime >= hideTime)
			{
				msgText.text = "";
				msgText.visible = false;
			}
			
			if (msgText.visible && Global.stage.stageHeight != stageHeight)
			{
				stageHeight = Global.stage.stageHeight;
				updatePosition();
			}
		}
		
		/**
		 * @inheritDoc
		 * 
		 */		
		public function dispose():void
		{
			msgText = null;
		}
	}
}