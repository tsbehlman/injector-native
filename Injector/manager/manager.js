( function() {
	"use strict";
	
	// DOM elements
	const list = document.getElementById( "list" );
	const form = document.getElementById( "form" );
	const title = document.getElementById( "title" ).firstChild;
	const newLink = document.getElementById( "new" );
	const deleteLink = document.getElementById( "delete" );
	const includeLabel = document.getElementById( "label-includes" );
	const excludeLabel = document.getElementById( "label-excludes" );
	const cssLabel = document.getElementById( "label-css" );
	const jsLabel = document.getElementById( "label-js" );
	
	const injections = new Map();
	let selectedListItem = newLink;
	
	bindNewForm();
	
	window.webkit && webkit.messageHandlers.injector.postMessage( {
		action: "retrieve"
	} );
	
	newLink.addEventListener( "click", event => {
		if( newLink !== selectedListItem ) {
			selectedListItem.classList.remove( "selected" );
			selectedListItem = newLink;
			deleteLink.disabled = true;
			bindNewForm();
		}
	}, false );
	
	deleteLink.addEventListener( "click", event => {
		if( selectedListItem === newLink ) {
			return;
		}
		
		const listItem = selectedListItem;
		
		(
			listItem.nextElementSibling ||
			listItem.previousElementSibling ||
			newLink
		).click();
		
		injections.delete( event.message );
		list.removeChild( listItem );
		deleteInjection( listItem.dataset.id );
	}, false );
	
	includeLabel.addEventListener( "click", clickLabel, false );
	excludeLabel.addEventListener( "click", clickLabel, false );
	cssLabel.addEventListener( "click", clickLabel, false );
	jsLabel.addEventListener( "click", clickLabel, false );
	
	for( const input of [ form.name, form.includes, form.excludes, form.styles, form.script ] ) {
		input.addEventListener( "input", enableSave, false );
	}
	
	for( const input of [ form.isEnabled, form.scriptLoadBehavior ] ) {
		input.addEventListener( "change", enableSave, false );
	}
	
	addKeyboardShortcut( "s", META, e => {
		e.preventDefault();
		form.save.click();
	} );
	
	function hideLabel( label ) {
		label.classList.add( "hidden" );
	}
	
	function showLabel( label ) {
		label.classList.remove( "hidden" );
	}
	
	function clickLabel() {
		( this.classList.contains( "hidden" ) ? showLabel : hideLabel )( this );
	}
	
	function enableSave() {
		form.save.disabled = false;
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
	
	function setTitle( newTitle ) {
		title.nodeValue = newTitle;
	}
	
	function setLabelState( includes, excludes, styles, script ) {
		( includes ? showLabel : hideLabel )( includeLabel );
		( excludes ? showLabel : hideLabel )( excludeLabel );
		( styles ? showLabel : hideLabel )( cssLabel );
		( script ? showLabel : hideLabel )( jsLabel );
	}
	
	function createListItem( id, injection ) {
		const item = document.createElement( "a" );
		
		item.dataset.id = id;
		
		if( !injection.isEnabled ) {
			item.className = "disabled";
		}
		item.href = "#";
		item.textContent = injection.name;
		item.addEventListener( "click", function( e ) {
			if( item !== selectedListItem ) {
				selectListItem( item );
				bindEditForm( item.dataset.id );
			}
		} );
		
		list.appendChild( item );
		return item;
	}
	
	function selectListItem( item ) {
		if( item !== selectedListItem ) {
			if( selectedListItem === newLink ) {
				deleteLink.disabled = false;
			}
			else {
				selectedListItem.classList.remove( "selected" );
			}
			
			item.classList.add( "selected" );
			selectedListItem = item;
		}
	}
	
	function constructDataFromForm() {
		const name = form.name.value,
			includes = form.includes.value,
			excludes = form.excludes.value,
			injection = {};
			
		injection.isEnabled = form.isEnabled.checked;
		injection.name = name.length ? name : "Untitled Injection";
		injection.includes = includes.length ? includes.split( "\n" ) : [ "*" ];
		injection.excludes = excludes.length ? excludes.split( "\n" ) : [];
		injection.styles = form.styles.value;
		injection.script = form.script.value;
		injection.scriptLoadBehavior = Number( form.scriptLoadBehavior.value );
		return injection;
	}
	
	function populateForm( injection ) {
		form.save.disabled = true;
		form.isEnabled.checked = injection.isEnabled;
		form.name.value = injection.name || "";
		form.includes.value = injection.includes.join( "\n" );
		form.excludes.value = injection.excludes.join( "\n" );
		form.styles.value = injection.styles || "";
		form.script.value = injection.script || "";
		form.scriptLoadBehavior.value = String( injection.scriptLoadBehavior );
	}
	
	function bindForm( injection, callback ) {
		populateForm( injection );
		
		form.onsubmit = function( e ) {
			const injection = constructDataFromForm();
			populateForm( injection );
			callback( injection );
			
			// Don't refresh the page
			e.preventDefault();
			return false;
		};
	}
	
	function bindEditForm( id ) {
		const injection = injections.get( id );
		setTitle( injection.name );
		setLabelState( injection.includes.length, injection.excludes.length, injection.styles.length, injection.script.length );
		bindForm( injection, function( injection ) {
			updateInjection( id, injection );
			injections.set( id, injection );
			
			// Always update display
			setTitle( injection.name );
			selectedListItem.firstChild.nodeValue = injection.name;
			
			if( injection.isEnabled ) {
				selectedListItem.classList.remove( "disabled" );
			}
			else {
				selectedListItem.classList.add( "disabled" );
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
			for( const injection of event.payload ) {
				injections.set( injection.id, injection );
				createListItem( injection.id, injection );
			}
			break;
		case "create":
			injections.set( event.payload.id, event.payload );
			selectListItem( createListItem( event.payload.id, event.payload ) );
			bindEditForm( event.payload.id );
			break;
		}
	}
} )();