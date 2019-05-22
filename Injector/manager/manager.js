(function() {
	"use strict";
	
	// DOM elements
	var list,
		form,
		title,
		newLink,
		deleteLink,
		includeLabel,
		excludeLabel,
		cssLabel,
		jsLabel;
	
	// The currently selected list item
	var selection = null;
	
	var styleCache;
	
	function newLinkHandler( event ) {
		if( this !== selection ) {
			clearSelection();
			bindNewForm();
		}
	}
	
	function deleteLinkHandler( event ) {
		if( selection === null || selection === newLink ) {
			return;
		}
	
		var element = selection;
	
		(
			element.nextElementSibling ||
			element.previousElementSibling ||
			newLink
		).click();
	
		removeItem( element.hash.substr( 1 ) );
	}
	
	function hideLabel( label ) {
		label.classList.add( "hidden" );
	}
	
	function showLabel( label ) {
		label.classList.remove( "hidden" );
	}
	
	function clickLabel() {
		if( this.classList.contains( "hidden" ) ) {
			showLabel( this );
			this.nextElementSibling.focus();
		}
		else {
			hideLabel( this );
		}
	}
	
	// Style storage
	function createItems() {
		//safari.self.tab.dispatchMessage( "items" );
	}
	
	function removeItem( key ) {
		//safari.self.tab.dispatchMessage( "removeItem", key );
	}
	
	function setItem( key, values ) {
		//safari.self.tab.dispatchMessage( "setItem", [ key, values ] );
	}
	
	// Manager application
	function start() {
		list = document.getElementById( "list" );
		form = document.getElementById( "form" );
		title = document.getElementById( "title" );
		newLink = document.getElementById( "new" );
		deleteLink = document.getElementById( "delete" );
		includeLabel = document.getElementById( "label-includes" );
		excludeLabel = document.getElementById( "label-excludes" );
		cssLabel = document.getElementById( "label-css" );
		jsLabel = document.getElementById( "label-js" );
	
		createItems();
	
		newLink.addEventListener( "click", newLinkHandler, false );
		deleteLink.addEventListener( "click", deleteLinkHandler, false );
	
		includeLabel.addEventListener( "click", clickLabel, false );
		excludeLabel.addEventListener( "click", clickLabel, false );
		cssLabel.addEventListener( "click", clickLabel, false );
		jsLabel.addEventListener( "click", clickLabel, false );
	}
	
	function getItemId( key ) {
		return "item-" + key;
	}
	
	function getListItem( key ) {
		return document.getElementById( getItemId( key ) );
	}
	
	function setTitle( newTitle ) {
		title.textContent = newTitle;
	}
	
	function setLabelState( includes, excludes, styles, script ) {
		( includes ? showLabel : hideLabel )( includeLabel );
		( excludes ? showLabel : hideLabel )( excludeLabel );
		( styles ? showLabel : hideLabel )( cssLabel );
		( script ? showLabel : hideLabel )( jsLabel );
	}
	
	function createItem( key, data ) {
		var item = document.createElement( "a" );
	
		item.id = getItemId( key );
	
		if( !data.enabled ) {
			item.className = "disabled";
		}
		item.href = "#" + key;
		item.textContent = data.name;
		item.addEventListener( "click", function( e ) {
			if( this !== selection ) {
				var key = this.hash.substr( 1 );
				markSelection( this );
				bindEditForm( key );
			}
		} );
	
		list.appendChild( item );
		return item;
	}
	
	function markSelection( element ) {
		if( element !== selection ) {
			if( selection === null ) {
				deleteLink.disabled = false;
			}
			else {
				selection.classList.remove( "selection" );
			}
			
			element.classList.add( "selection" );
			selection = element;
		}
	}
	
	function clearSelection() {
		if( selection !== null ) {
			selection.classList.remove( "selection" );
			selection = null;
		}
		deleteLink.disabled = true;
	}
	
	function constructDataFromForm() {
		var name = form.name.value,
			includes = form.includes.value,
			excludes = form.excludes.value,
			data = {};
		
		data.name = name.length ? name : "Untitled Injection";
		data.enabled = form.enabled.checked;
		data.includes = includes.length ? sanitizeDomains( includes.split( "\n" ) ) : [ "*" ];
		data.excludes = excludes.length ? sanitizeDomains( excludes.split( "\n" ) ) : [];
		data.styles = form.styles.value;
		data.script = form.script.value;
		data.onload = Number( form.onload.value );
		return data;
	}
	
	function populateForm( data ) {
		form.name.value = data.name || "";
		form.includes.value = data.includes.join( "\n" );
		form.excludes.value = data.excludes.join( "\n" );
		form.styles.value = data.styles || "";
		form.script.value = data.script || "";
		form.onload.checked = data.onload;
		form.enabled.checked = data.enabled;
	}
	
	function bindForm( data, callback ) {
		
		populateForm( data );
		
		form._submitCallback && form.removeEventListener( "submit", form._submitCallback, false ); // Cleanup
		
		form._submitCallback = function( e ) {
			var formData = constructDataFromForm();
			populateForm( formData );
			callback( formData );
			
			// Don't refresh the page
			e.preventDefault();
			return false;
		};
		
		form.addEventListener( "submit", form._submitCallback, false );
	}
	
	function bindEditForm( key ) {
		var data = styleCache.get( key );
		setTitle( data.name );
		setLabelState( data.includes.length, data.excludes.length, data.styles.length, data.script.length );
		bindForm( data, function( formData ) {
			setItem( key, formData );
	
			var item = getListItem( key );
			// Always update display
			setTitle( formData.name );
			item.firstChild.nodeValue = formData.name;
	
			if( formData.enabled ) {
				item.classList.remove( "disabled" );
			}
			else {
				item.classList.add( "disabled" );
			}
		});
	}
	
	function bindNewForm() {
		setTitle( "New Injection" );
		setLabelState( true, false, true, true );
		bindForm( { enabled: true, includes: [], excludes: [] }, function( formData ) {
			var key = "" + Date.now();
			setItem( key, formData );
	
			var item = createItem( key, formData );
			item.click();
	
			if( !formData.enabled ) {
				item.classList.add("disabled");
			}
		} );
	}
	
	function handleMessage( event ) {
		switch( event.name ) {
		case "items":
			styleCache = new Map( event.message );
			styleCache.forEach( function( data, key ) {
				createItem( key, data );
			} );
	
			var hash = window.location.hash;
	
			if( hash.indexOf( "new", 1 ) === 1 ) {
				newLink.click();
				if( hash.length > 4 ) {
					form.includes.value = decodeURIComponent( hash.substring( 5 ) );
				}
			}
			else if( hash.length > 0 ) {
				getListItem( hash.substring( 1 ) ).click();
			}
			else {
				newLink.click();
			}
			break;
		case "itemRemoved":
			styleCache.delete( event.message );
			list.removeChild( getListItem( event.message ) );
			break;
		case "itemUpdated":
			styleCache.set( event.message[ 0 ], event.message[ 1 ] );
			if( event.message[ 0 ] === selection.hash.substr( 1 ) ) {
				form.enabled.checked = event.message[ 1 ].enabled;
			}
			break;
		}
	}
	
	//safari.self.addEventListener( "message", handleMessage, false );
	window.addEventListener( "DOMContentLoaded", start, false );
} )();
