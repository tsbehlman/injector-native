(function() {
	"use strict";
	
	// DOM elements
	let list,
		form,
		title,
		newLink,
		deleteLink,
		includeLabel,
		excludeLabel,
		cssLabel,
		jsLabel;
	
	// The currently selected list item
	let selection = null;
	
	let styleCache;
	
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
		
		const element = selection;
		
		(
			element.nextElementSibling ||
			element.previousElementSibling ||
			newLink
		).click();
		
		styleCache.delete( event.message );
		list.removeChild( element );
		deleteInjection( element.dataset.id );
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
	function retrieveInjections() {
		webkit.messageHandlers.injector.postMessage( {
			action: "retrieve"
		} );
	}
	
	function deleteInjection( id ) {
		webkit.messageHandlers.injector.postMessage( {
			action: "delete",
			id
		} );
	}
	
	function createInjection( injection ) {
		webkit.messageHandlers.injector.postMessage( {
			action: "create",
			injection
		} );
	}
	
	function updateInjection( id, injection ) {
		webkit.messageHandlers.injector.postMessage( {
			action: "update",
			id,
			injection
		} );
	}
	
	// Manager application
	function start() {
		list = document.getElementById( "list" );
		form = document.getElementById( "form" );
		title = document.getElementById( "title" ).firstChild;
		newLink = document.getElementById( "new" );
		deleteLink = document.getElementById( "delete" );
		includeLabel = document.getElementById( "label-includes" );
		excludeLabel = document.getElementById( "label-excludes" );
		cssLabel = document.getElementById( "label-css" );
		jsLabel = document.getElementById( "label-js" );
		
		retrieveInjections();
		
		newLink.addEventListener( "click", newLinkHandler, false );
		deleteLink.addEventListener( "click", deleteLinkHandler, false );
		
		includeLabel.addEventListener( "click", clickLabel, false );
		excludeLabel.addEventListener( "click", clickLabel, false );
		cssLabel.addEventListener( "click", clickLabel, false );
		jsLabel.addEventListener( "click", clickLabel, false );
		
		newLink.click();
	}
	
	function setTitle( newTitle ) {
		title.nodeValue = newTitle;
	}
	
	function setLabelState( includes, excludes, styles, script ) {
		( includes ? showLabel : hideLabel )( includeLabel );
		( excludes ? showLabel : hideLabel )( excludeLabel );
		( styles ? showLabel : hideLabel )( cssLabel );
		( script ? showLabel : hideLabel )( jsLabel );
	}
	
	function createItem( key, data ) {
		const item = document.createElement( "a" );
		
		item.dataset.id = key;
		
		if( !data.isEnabled ) {
			item.className = "disabled";
		}
		item.href = "#";
		item.textContent = data.name;
		item.addEventListener( "click", function( e ) {
			if( this !== selection ) {
				markSelection( this );
				bindEditForm( this.dataset.id );
			}
		} );
		
		list.appendChild( item );
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
		const name = form.name.value,
			includes = form.includes.value,
			excludes = form.excludes.value,
			data = {};
			
		data.isEnabled = form.isEnabled.checked;
		data.name = name.length ? name : "Untitled Injection";
		data.includes = includes.length ? includes.split( "\n" ) : [ "*" ];
		data.excludes = excludes.length ? excludes.split( "\n" ) : [];
		data.styles = form.styles.value;
		data.script = form.script.value;
		data.scriptLoadBehavior = Number( form.scriptLoadBehavior.value );
		return data;
	}
	
	function populateForm( data ) {
		form.isEnabled.checked = data.isEnabled;
		form.name.value = data.name || "";
		form.includes.value = data.includes.join( "\n" );
		form.excludes.value = data.excludes.join( "\n" );
		form.styles.value = data.styles || "";
		form.script.value = data.script || "";
		form.scriptLoadBehavior.value = String( data.scriptLoadBehavior );
	}
	
	function bindForm( data, callback ) {
		populateForm( data );
		
		form.onsubmit = function( e ) {
			const formData = constructDataFromForm();
			populateForm( formData );
			callback( formData );
			
			// Don't refresh the page
			e.preventDefault();
			return false;
		};
	}
	
	function bindEditForm( key ) {
		const data = styleCache.get( key );
		setTitle( data.name );
		setLabelState( data.includes.length, data.excludes.length, data.styles.length, data.script.length );
		bindForm( data, function( formData ) {
			updateInjection( key, formData );
			styleCache.set( key, formData );
			
			// Always update display
			setTitle( formData.name );
			selection.firstChild.nodeValue = formData.name;
			
			if( formData.isEnabled ) {
				selection.classList.remove( "disabled" );
			}
			else {
				selection.classList.add( "disabled" );
			}
		});
	}
	
	function bindNewForm() {
		setTitle( "New Injection" );
		setLabelState( true, false, true, true );
		bindForm( { isEnabled: true, includes: [], excludes: [], scriptLoadBehavior: 0 }, createInjection );
	}
	
	window.handleMessage = function( event ) {
		switch( event.action ) {
		case "retrieve":
			while( list.firstChild ) {
				list.removeChild( list.firstChild );
			}
			styleCache = new Map( event.payload.map( injection => [ injection.id, injection ] ) );
			styleCache.forEach( function( data, key ) {
				createItem( key, data );
			} );
			break;
		case "select":
			markSelection( list.querySelector( `[data-id="${event.id}"]` ) );
			bindEditForm( event.id );
			break;
		}
	}
	
	window.addEventListener( "DOMContentLoaded", start, false );
} )();
