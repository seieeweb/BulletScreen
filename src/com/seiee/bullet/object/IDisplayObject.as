package com.seiee.bullet.object
{
	/**
	 * <b>IDisplayObjectInterface</b>
	 * <br>Defining external controlling functions for a display class.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/18
	 * <br>Created on: 2014/10/8
	 */
	public interface IDisplayObject
	{
		/**
		 * Update the bullet with the given current time. 
		 * @param currentTime Current time, used to move the bullet.
		 * 
		 */		
		function update(currentTime:Date):void;
		
		/**
		 * Dispose the current bullet and its resources.
		 * 
		 */		
		function dispose():void;
	}
}