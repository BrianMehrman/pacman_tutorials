﻿package game.content.enemies {	import game.objects.Enemy;		public class Inky extends Enemy {		public function Inky(xTile:uint, yTile:uint, dirX:int, dirY:int, delay, clientHero:Boolean, initTarget:GameObject, movementHandler:MovementHandler):void {			super(24, 24, xTile, yTile, dirX, dirY, 5, 10, 2, delay, clientHero, initTarget, movementHandler);		}	}	}