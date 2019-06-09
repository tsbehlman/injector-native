( function() {
	"use strict";
	
	const KEY_BIT_CTRL  = 0;
	const KEY_BIT_ALT   = 1;
	const KEY_BIT_META  = 2;
	const KEY_BIT_SHIFT = 3;
	
	function keyboardShortcutIdentifier( key, modifiers ) {
		return modifiers + key;
	}
	
	const keyboardShortcuts = new Map();
	
	document.addEventListener( "keypress", e => {
		const modifiers =
			Number( e.ctrlKey  ) << KEY_BIT_CTRL |
			Number( e.altKey   ) << KEY_BIT_ALT  |
			Number( e.metaKey  ) << KEY_BIT_META |
			Number( e.shiftKey ) << KEY_BIT_SHIFT;
		const shortcut = keyboardShortcutIdentifier( e.key.toLowerCase(), modifiers );
		const action = keyboardShortcuts.get( shortcut );
		if( action !== undefined ) {
			action( e );
		}
	}, false );
	
	window.CTRL  = 1 << KEY_BIT_CTRL,
	window.ALT   = 1 << KEY_BIT_ALT,
	window.META  = 1 << KEY_BIT_META,
	window.SHIFT = 1 << KEY_BIT_SHIFT,
	window.addKeyboardShortcut = function( key, modifiers, action ) {
		keyboardShortcuts.set( keyboardShortcutIdentifier( key, modifiers ), action );
	}
} )();