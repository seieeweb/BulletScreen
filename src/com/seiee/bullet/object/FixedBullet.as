package com.seiee.bullet.object
{
	import com.seiee.bullet.data.BulletData;
	
	/**
	 * <b>FixedBullet Class</b>
	 * <br>The class is a sprite showing a bullet on the top or on the bottom.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/21
	 * <br>Created on: 2014/10/15
	 */
	public class FixedBullet extends Bullet
	{
		/**
		 * The width of the stage. 
		 */		
		protected var stageWidth:Number;
		
		/**
		 * Initializing function. 
		 * @param data BulletData
		 * 
		 */		
		public function FixedBullet(data:BulletData)
		{
			super(data);
			init();
		}
		
		/**
		 * The initialzing function.
		 */	
		private function init():void
		{
			stageWidth = Global.stage.stageWidth;
			updatePosition();
		}
			
		override protected function createTextField():void
		{
			super.createTextField();
			this.textField.x = (stageWidth - textWidth) / 2;
		}
		
		override public function canShowNext():Boolean
		{
			//const BULLET_WAIT_PERCENT:Number = 0.1;
			//return ((textField.x + textWidth) / stage.stageWidth + BULLET_WAIT_PERCENT) < 1;
			return (showWeight >= 100);
		}
		
		override protected function getShowTime(textWidth:Number):Number
		{
			return super.getShowTime(textWidth) * Global.config.FIXED_TIME_MULTIPLIER;
		}
		
		override public function update(currentTime:Date):void
		{
			if (isComplete()) return;
			
			if (Global.stage.stageWidth != stageWidth)
			{
				stageWidth = Global.stage.stageWidth;
				updatePosition();
			}
			
			var offset:Number = Math.max(currentTime.getTime() - data.postTime.getTime(), 0);
			
			if (offset > showTime)
			{
				complete = true;
				removeChild(textField);
			}
		}
		
		/**
		 * Update the position of the TextField object accordint to stageWidth. 
		 * 
		 */		
		public function updatePosition():void
		{
			stageWidth = Global.stage.stageWidth;
			this.textField.x = (stageWidth - textWidth) / 2;
		}
		
		override public function get showWeight():int
		{
			const BULLET_WAIT_PERCENT:Number = Global.config.BULLET_WAIT_PERCENT;
			var currentTime:Date = new Date();
			var offset:Number = Math.max(currentTime.getTime() - data.postTime.getTime(), 0);
			var weight:Number = offset / showTime - BULLET_WAIT_PERCENT;
			return Math.ceil(weight * 100);
		}
	}
}