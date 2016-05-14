package com.seiee.bullet.object
{
	import com.seiee.bullet.data.BulletData;
	
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	/**
	 * <b>Bullet Class</b>
	 * <br>The class is a sprite showing a bullet.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2015/10/21
	 * <br>Created on: 2014/10/8
	 */
	public class Bullet extends Sprite implements IDisplayObject
	{
		/**
		 * BulletData of a bullet.
		 */
		public var data:BulletData;
		
		/**
		 * Bullet textfield of a bullet.
		 */
		protected var textField:TextField;
		/**
		 * A var showing whether the bullet has moved out of the screen.
		 */
		protected var complete:Boolean;
		/**
		 * Private var for the attribute textWidth.
		 */
		private var _textWidth:Number = 0;
		/**
		 * Private var for the attribute showTime.
		 */
		private var _showTime:Number = 0;
		
		/**
		 * Initializing function. 
		 * @param data BulletData
		 * 
		 */		
		public function Bullet(data:BulletData)
		{
			super();
			this.data = data;
			init();
		}
		
		/**
		 * Init function.
		 */
		private function init():void
		{
			createTextField();
			initTimer();
		}
		
		/**
		 * Create TextField.
		 */
		protected function createTextField():void
		{
			this.textField = new TextField();
			this.textField.selectable = false;
			this.textField.multiline = false;
			this.textField.autoSize = TextFieldAutoSize.LEFT;
			
			var format:TextFormat = new TextFormat();
			format.font = Global.config.FONT_FAMILY;
			format.color = data.color;
			format.size = fontSize;
			this.textField.defaultTextFormat = format;
			this.textField.embedFonts = Global.config.useExternalFont;
			
			var filter:GlowFilter = new GlowFilter(0x000000, 1, 5, 5, 2);
			var textFilters:Array = new Array();
			textFilters.push(filter);
			this.textField.filters = textFilters;
			this.textField.antiAliasType = AntiAliasType.ADVANCED;
			this.textField.cacheAsBitmap = true;
			
			this.textField.text = data.text;
			var metrics:TextLineMetrics = this.textField.getLineMetrics(0);
			_textWidth = metrics.width;
			
			this.textField.x = Global.stage.stageWidth;
			this.textField.y = 0;
			addChild(textField);
		}
		
		/**
		 * Set framecounts.
		 */
		private function initTimer():void
		{
			complete = false;
			_showTime = getShowTime(_textWidth);
		}
		
		/**
		 * Getting the time needed for showing the bullet.
		 * @param textWidth Width of the text.
		 * @return The time needed. The unit is millisecond.
		 * 
		 */		
		protected function getShowTime(textWidth:Number):Number
		{
			return Global.config.BULLET_TIME;
			
			/*const TIME_PER_CHAR:Number = Global.config.TIME_PER_CHAR;
			const MIN_CALC_LEN:Number = Global.config.MIN_CALC_LEN;
			const POW_BASE:Number = Global.config.POW_BASE;
			var charNum:Number = textWidth / fontSize;
			return (charNum > MIN_CALC_LEN) ? 
				(TIME_PER_CHAR * Math.pow(POW_BASE, charNum - MIN_CALC_LEN) * charNum) : 
				(TIME_PER_CHAR * MIN_CALC_LEN);
			*/
		}
		
		/**
		 * @inheritDoc
		 */		
		public function update(currentTime:Date):void
		{
			if (isComplete()) return;
			
			var offset:Number = currentTime.getTime() - data.postTime.getTime();
			var moveUnit:Number = (stage.stageWidth + textWidth) / showTime;
			var nowX:Number = stage.stageWidth - moveUnit * offset;
			textField.x = nowX;
			
			if (offset > showTime)
			{
				complete = true;
				removeChild(textField);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			data = null;
		}

		/**
		 * Getting whether the bullet is out of the screen.
		 */
		public function isComplete():Boolean
		{
			return complete;
		}
		
		/**
		 * Getting whether a next bullet can show on the BulletLane.
		 */
		public function canShowNext():Boolean
		{
			//const BULLET_WAIT_PERCENT:Number = 0.1;
			//return ((textField.x + textWidth) / stage.stageWidth + BULLET_WAIT_PERCENT) < 1;
			return (showWeight <= 100);
		}
		
		/**
		 * Size of the text.
		 */
		protected function get fontSize():Number
		{
			return Global.config.FONT_SIZE;
		}
		
		/**
		 * The width of the bullet text.
		 */
		public function get textWidth():Number
		{
			return _textWidth;
		}

		/**
		 * The time given to show the bullet.
		 * Calculated by the private function getShowTime().
		 * <br>The unit is millisecond.
		 */		
		public function get showTime():Number
		{
			return _showTime;
		}
		
		/**
		 * The weight of the bullet.
		 */		
		public function get showWeight():int
		{
			const BULLET_WAIT_PERCENT:Number = Global.config.BULLET_WAIT_PERCENT;
			var weight:Number = (textField.x + textWidth) / stage.stageWidth + BULLET_WAIT_PERCENT;
			return Math.ceil(weight * 100);
		}
		
		/**
		 * The position of the bullet. 
		 * 
		 */		
		public function get position():int
		{
			return data.position;
		}
	}
}