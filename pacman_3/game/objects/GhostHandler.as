﻿package game.objects {	import flash.display.MovieClip;		public class GhostHandler {				protected var _ghosts:Array = new Array();		protected var _tilesContainer:MovieClip;				public function GhostHandler(tilesContainer:MovieClip) {			// constructor code			this._tilesContainer = tilesContainer;		}		public function addGhost(ghost:Ghost):void {			this._ghosts.push(ghost);			this._tilesContainer.addChild(ghost);		}	}	}