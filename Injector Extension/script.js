( function() {
	"use strict";
	
	function wrapScriptInIIFE( name, script ) {
		return `(function() {\n${ script }\n})();`;
	}
	
	let injectedElements = [];
	let injectionPromise = Promise.resolve();
	
	async function updateInjections( injections ) {
		await injectionPromise;
		
		for( const element of injectedElements ) {
			document.head.removeChild( element );
		}
		
		injectedElements = [];
		let promises = [];
		
		for( const injection of injections ) {
			const style = document.createElement( "style" );
			const script = document.createElement( "script" );
			style.dataset.injection = injection.name;
			script.dataset.injection = injection.name;
			injectedElements.push( style, script );
			style.appendChild( document.createTextNode( injection.styles ) );
			script.appendChild( document.createTextNode( wrapScriptInIIFE( injection.name, injection.script ) ) );
			document.head.appendChild( style );
			promises.push( scriptLoadPromises[ injection.scriptLoadBehavior ].then( () => {
				document.head.appendChild( script );
			} ) );
		}
		
		injectionPromise = Promise.all( promises );
	}
	
	const scriptLoadPromises = [
		Promise.resolve(),
		new Promise( resolve => {
			const handler = e => {
				document.removeEventListener( "DOMContentLoaded", handler, false );
				resolve();
			};
			document.addEventListener( "DOMContentLoaded", handler, false );
		} ),
		new Promise( resolve => {
			const handler = e => {
				document.removeEventListener( "load", handler, false );
				resolve();
			};
			document.addEventListener( "load", handler, false );
		} )
	];
	
	safari.self.addEventListener( "message", event => {
		switch( event.name ) {
		case "update":
			updateInjections( event.message.injections );
			break;
		}
	} );
	
	safari.extension.dispatchMessage( "update" );
} )();
