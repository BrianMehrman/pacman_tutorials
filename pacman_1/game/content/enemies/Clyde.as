﻿package game.content.enemies {	import game.objects.Enemy;		public class Clyde extends Enemy {		public function Clyde(xTile:uint, yTile:uint, dirX:int, dirY:int, clientHero:Boolean, initTarget:GameObject, movementHandler:MovementHandler):void {			super(24, 24, xTile, yTile, dirX, dirY, 5, 10, 2, clientHero, initTarget, movementHandler);		}	}	}