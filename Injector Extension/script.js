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
				script.appendChild( document.createTextNode( wrapScriptInIIFE( injection.name, inject
				promises.push( scriptLoadPromises[ injection.scriptLoadBehavior ].then( () => {
					document.head.appendChild( script );
				} ) );
			}
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
