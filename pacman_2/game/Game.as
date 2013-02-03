﻿package game {	import game.content.tiles.*;	import game.objects.Hero;	import game.map.Map;	import game.objects.GameObject;		import flash.events.Event;	import flash.display.MovieClip;	import flash.utils.getDefinitionByName;	import flash.display.StageScaleMode;	import flash.display.StageAlign;		public class Game {		public static const NORMAL:String = "normal";		public static const TILE_BY_TILE:String = "tileByTile";		public static const CLICK:String = "click";				public static const FILLER_TILE_CLASS:String = "game.content.tiles.FillerTile";				public var tilesContainer:MovieClip;				public var gameTiles:Object;		public var tileW:int;		public var tileH:int;		public var map:Map;		public var clientHero:Hero;		public var gravity:int;		public var tiltRatio:Number;		public var strafing:Boolean;		public var movementType:String;		protected var _currentState:String;		public var gameObjects:Array;				public function Game(tilesContainer:MovieClip, tileW:int, tileH:int, gravity:int, tiltRatio:Number = 1, strafing:Boolean = true, movementType:String = Game.NORMAL) {			// constructor code			this.tilesContainer = tilesContainer;			this.tileW = tileW;			this.tileH = tileH;			this.gravity = gravity;			this.tiltRatio = tiltRatio;			this.strafing = strafing;			this.movementType = movementType;			this.gameObjects = new Array();			this.tilesContainer.addEventListener(Event.ADDED_TO_STAGE, this.setResizeEvent);		}		protected function setResizeEvent(event:Event) {			this.tilesContainer.stage.scaleMode = StageScaleMode.NO_SCALE;			this.tilesContainer.stage.align = StageAlign.TOP_LEFT;			this.tilesContainer.stage.addEventListener(Event.RESIZE, this.scrollToClientHero);		}				/**		 *		 * Sets the current state of the game		 *		 */		 public function set currentState(newState:String):void {			 this._currentState = newState;		 }				 public function get currentState():String {			 return this._currentState;		 }		 		 		 public function addGameObject(object:GameObject):void {			 this.gameObjects.push(object);		 }		 		 public function restartLevel():void {			 			 		 }		 		 		/**		 *		 * Builds the passed <code>Map</code> into the <code>gameTiles</code> Object. Also adds the tiles to the <code>tilesContainer</code> object.		 *		 * @param map		 *		 */		 		 public function buildMap(map:Map):void {			 var gameTiles:Object = new Object();			 var mapWidth:int = map.mapArray[0].length;			 var mapHeight:int = map.mapArray.length;			 var xStart:int = 0;			 var xEnd:int = mapWidth;			 var yStart:int = 0;			 var yEnd:int = mapHeight;			 			 for(var x=xStart;x<xEnd;x++){				 gameTiles[x] = new Object();			 }			 			 var ClassReference:Class;			 var SpawnReference:Class;			 for(var y = yStart; y < yEnd; y++) {				 for(x = xStart; x< xEnd; x++) {					 ClassReference = getDefinitionByName(map.tileset[map.mapArray[y][x]]) as Class;					 if(map.tilespawns[map.mapArray[y][x]] != "") {						 SpawnReference = getDefinitionByName(map.tilespawns[map.mapArray[y][x]]) as Class;						 gameTiles[x][y] = new ClassReference(SpawnReference);					 }					 else {						 gameTiles[x][y] = new ClassReference();					 }					 gameTiles[x][y].x = x*this.tileW;					 gameTiles[x][y].y = y*this.tileH;					 this.tilesContainer.addChild(gameTiles[x][y]);				 }			 }			 			 this.gameTiles = gameTiles;			 this.map = map;			 this.scrollToClientHero(null);		 }					protected function scrollToClientHero(event:Event):void {			if(this.clientHero) {				this.scroll(this.clientHero);			}		}				public function scroll(object:GameObject):void {						if(this.tilesContainer.stage.stageWidth < this.tilesContainer.width) {				var leftPixelLimit:int = this.tilesContainer.stage.stageWidth/2;				var rightPixelLimit:int = this.map.mapArray[0].length*this.tileW - this.tilesContainer.stage.stageWidth/2;								if(object.xOnPlane < leftPixelLimit) {					this.tilesContainer.x = 0;				} else if (object.xOnPlane > rightPixelLimit) {					this.tilesContainer.x = 0 - this.map.mapArray[0].length*this.tileW + this.tilesContainer.stage.stageWidth;				} else {					this.tilesContainer.x = leftPixelLimit - object.xOnPlane;				}			} else {				this.tilesContainer.x = (this.tilesContainer.stage.stageWidth - this.tilesContainer.width)/2;			}						if (this.tilesContainer.stage.stageHeight < this.tilesContainer.height) {				var topPixelLimit:int = this.tilesContainer.stage.stageHeight/2;				var bottomPixelLimit:int = this.map.mapArray.length*this.tileH - this.tilesContainer.stage.stageHeight/2;				if(object.yOnPlane < topPixelLimit) {					this.tilesContainer.y = 0;				} else if (object.yOnPlane > bottomPixelLimit) {					this.tilesContainer.y = 0 - this.map.mapArray.length*this.tileH + this.tilesContainer.stage.stageHeight;				} else { 					this.tilesContainer.y = topPixelLimit-object.yOnPlane;				}			} else {				this.tilesContainer.y = (this.tilesContainer.stage.stageHeight-this.tilesContainer.heigth)/2;			}		}	}}