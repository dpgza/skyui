﻿import Shared.GlobalFunc;

class skyui.widgets.WidgetBase extends MovieClip
{
  /* CONSTANTS */
	
	private static var MODES: Array = ["All", "Favor", "MovementDisabled", "Swimming", "WarhorseMode", "HorseMode", "InventoryMode", "BookMode", "DialogueMode", "StealthMode", "SleepWaitMode", "BarterMode", "TweenMode", "WorldMapMode", "JournalMode", "CartMode", "VATSPlayback"];
	//private static var CROSSHAIR_MODES: Array = ["All", "Favor", "DialogueMode", "StealthMode", "Swimming", "HorseMode", "WarHorseMode"];

	private static var ANCHOR_LEFT: String		= "left";
	private static var ANCHOR_RIGHT: String		= "right";
	private static var ANCHOR_CENTER: String	= "center";
	private static var ANCHOR_TOP: String		= "top";
	private static var ANCHOR_BOTTOM: String	= "bottom";
	
	
  /* PRIVATE VARIABLES */
  
	private var _rootPath: String = "";

	private var _hudMetrics: Object;
  
	private var _clientInfo: Object;
	private var _widgetID: String;
	private var _widgetHolder: MovieClip;

	private var __x: Number = 0;
	private var __y: Number = 0;

	private var _vAnchor: String = "top";
	private var _hAnchor: String = "left";
	
	
  /* INITIALIZATION */
  
	public function WidgetBase()
	{
		_clientInfo = {};
		_widgetHolder = _parent;
		_widgetID = _widgetHolder._name;
		
		// Allows for preview in Flash Player
		if (_global.gfxPlayer)
			_global.gfxExtensions = true;
		else
			_widgetHolder._visible = false;
	}
	
		
  /* PUBLIC FUNCTIONS */
  
	public function setRootPath(a_path: String): Void
	{
		_rootPath = a_path;
	}

	public function setHudMetrics(a_hudMetrics: Object): Void
	{
		_hudMetrics = a_hudMetrics;
	}	

	// @Papyrus
	public function setClientInfo(a_clientString: String): Void
	{
		var widget = this;
		var clientInfo: Object = new Object();
		//[ScriptName <formName (formID)>]
		var lBrackIdx: Number = 0;
		var lInequIdx: Number = a_clientString.indexOf("<");
		var lParenIdx: Number = a_clientString.indexOf("(");
		var rParenIdx: Number = a_clientString.indexOf(")");
		
		clientInfo["scriptName"] = a_clientString.slice(lBrackIdx + 1, lInequIdx - 1);
		clientInfo["formName"] = a_clientString.slice(lInequIdx + 1, lParenIdx - 1);
		clientInfo["formID"] = a_clientString.slice(lParenIdx + 1, rParenIdx);
		
		widget.clientInfo = clientInfo;
	}

	// @Papyrus
	public function setModes(/* a_visibleMode0: String, a_visibleMode1: String, ... */): Void
	{
		var numValidModes: Number = 0;
		// Clear all modes
		for (var i=0; i<MODES.length; i++)
			delete(_widgetHolder[MODES[i]]);
			
		for (var i=0; i<arguments.length; i++) {
			var m = arguments[i];
			if (MODES.indexOf(m) != undefined) {
				_widgetHolder[m] = true;
				numValidModes++;
			}
		}
		if (numValidModes == 0) // TODO
			skse.SendModEvent("SKIWF_widgetError", "NoValidModes", Number(_widgetID));
		
		var hudMode: String = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
		_widgetHolder._visible = _widgetHolder.hasOwnProperty(hudMode);
			
		_root.HUDMovieBaseInstance.HudElements.push(_widgetHolder);
	}

	// @Papyrus
	public function setHAnchor(a_hAnchor: String): Void
	{
		var hAnchor: String = a_hAnchor.toLowerCase();

		if (_hAnchor == hAnchor)
			return;

		_hAnchor = hAnchor;

		invalidateSize();
	}

	// @Papyrus
	public function setVAnchor(a_vAnchor: String): Void
	{
		var vAnchor: String = a_vAnchor.toLowerCase();

		if (_vAnchor == vAnchor)
			return;

		_vAnchor = vAnchor;

		invalidateSize();
	}

	// @Papyrus
	public function setPositionX(a_positionX: Number): Void
	{
		__x = a_positionX;
		updatePosition();	
	}

	// @Papyrus
	public function setPositionY(a_positionY: Number): Void
	{
		__y = a_positionY;
		updatePosition();
	}

	// @Papyrus
	public function setAlpha(a_alpha: Number): Void
	{
		_alpha = a_alpha;
	}

  /* PRIVATE FUNCTIONS */
	// Override if widget width depends on property other than _width
	// See skyui.widgets.meter.MeterWidget as an example
	private function getWidth(): Number
	{
		return _width;
	}

	// Override if widget height depends on property other than _height
	private function getHeight(): Number
	{
		return _height;
	}

	private function invalidateSize(): Void
	{
		updateAnchor();
	}

	private function updateAnchor(): Void
	{
		var xOffset: Number = getWidth();
		var yOffset: Number = getHeight();
		
		if (_hAnchor == ANCHOR_RIGHT)
			_widgetHolder._x = -xOffset;
		else if (_hAnchor == ANCHOR_CENTER)
			_widgetHolder._x = -xOffset/2;
		else
			_widgetHolder._x = 0;

		if (_vAnchor == ANCHOR_BOTTOM)
			_widgetHolder._y = -yOffset;
		else if (_vAnchor == ANCHOR_CENTER)
			_widgetHolder._y = -yOffset/2;
		else
			_widgetHolder._y = 0;

		// Anchor or offsets could have changed, so update position
		updatePosition();
	}

	private function updatePosition(): Void
	{
		// Removed, because we want absolute positioning, not relative positioning.
		/*
		var newX: Number;
		var newY: Number;

		switch(_hAnchor) {
			case ANCHOR_RIGHT:
				// 0 -> _hudMetrics.hMax
				// 1280 -> -_hudMetrics.hMin
				newX = GlobalFunc.Lerp(_hudMetrics.hMax, -_hudMetrics.hMin, 0, 1280, __x);
				break;

			case ANCHOR_CENTER:
				// 0 -> 0
				// 640 -> _hudMetrics.hCenter
				newX = GlobalFunc.Lerp(0, _hudMetrics.hCenter, 0, 640, __x);
				break;
			
			case ANCHOR_LEFT:
			default:
				// 0 -> -_hudMetrics.hMin
				// 1280 -> _hudMetrics.hMax
				newX = GlobalFunc.Lerp(-_hudMetrics.hMin, _hudMetrics.hMax, 0, 1280, __x);
		}

		switch(_vAnchor) {
			case ANCHOR_BOTTOM:
				// 0 -> _hudMetrics.vMax
				// 720 -> -_hudMetrics.vMin
				newY = GlobalFunc.Lerp(_hudMetrics.vMax, -_hudMetrics.vMin, 0, 720, __y);
				break;

			case ANCHOR_CENTER:
				// 0 -> 0
				// 360 -> _hudMetrics.vCenter
				newY = GlobalFunc.Lerp(0, _hudMetrics.hCenter, 0, 360, __x);
				break;

			case ANCHOR_TOP:
			default:
				// 0 -> -_hudMetrics.vMin
				// 720 -> _hudMetrics.vMax
				newY = GlobalFunc.Lerp(-_hudMetrics.vMin, _hudMetrics.vMax, 0, 720, __y);
		}

		_x = newX;
		_y = newY;
		*/

		// 0 -> -_hudMetrics.hMin
		// 1280 -> _hudMetrics.hMax
		_x = GlobalFunc.Lerp(-_hudMetrics.hMin, _hudMetrics.hMax, 0, 1280, __x);
		// 0 -> -_hudMetrics.vMin
		// 720 -> _hudMetrics.vMax
		_y = GlobalFunc.Lerp(-_hudMetrics.vMin, _hudMetrics.vMax, 0, 720, __y);
	}
}