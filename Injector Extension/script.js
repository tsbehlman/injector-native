( function() {
	"use strict";
	
	function wrapScriptInIIFE( name, script ) {
		return `(function() {\n${ script }\n})();`;
	}
	
	let injectedElements = [];
	let injectionPromise = Promise.resolve();
	
	async function updateInjections( injections ) {
		await injectionPromise;
		
		for( const injectedElement of injectedElements ) {
			document.head.removeChild( injectedElement );
		}
		
		injectedElements = [];
		let promises = [];
		
		for( const injection of injections ) {
			if( injection.styles ) {
				const style = document.createElement( "style" );
				style.dataset.injection = injection.name;
				injectedElements.push( style );
				style.appendChild( document.createTextNode( injection.styles ) );
				document.head.appendChild( style );
			}
			if( injection.script ) {
				const script = document.createElement( "script" );
				script.dataset.injection = injection.name;
				injectedElements.push( script );
				script.appendChild( document.createTextNode( wrapScriptInIIFE( injection.name, injection.script ) ) );
				promises.push( scriptLoadPromises[ injection.scriptLoadBehavior ].then( () => {
					document.head.appendChild( script );
				} ) );
			}
		}
		
		await Promise.all( promises );
	}
	
	function listenForOneEvent( element, event, useCapture ) {
		return new Promise( function( resolve ) {
			const handler = e => {
				element.removeEventListener( event, handler, useCapture );
				resolve();
			};
			element.addEventListener( event, handler, useCapture );
		} )
	}
	
	const scriptLoadPromises = [
		Promise.resolve(),
		document.readyState !== "loading" ? Promise.resolve() : listenForOneEvent( document, "DOMContentLoaded", false ),
		document.readyState === "complete" ? Promise.resolve() : listenForOneEvent( window, "load", false ),
	];
	
	safari.self.addEventListener( "message", event => {
		switch( event.name ) {
		case "update":
			injectionPromise = updateInjections( event.message.injections );
			break;
		}
	} );
	
	safari.extension.dispatchMessage( "update" );
} )();
