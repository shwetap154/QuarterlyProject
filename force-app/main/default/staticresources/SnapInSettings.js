let chasitorControlsChildren;

function hideShowInit() {

	// Initialize listeners
	window.addEventListener("hide-message-input", hideMessageInput, false);
	window.addEventListener("show-message-input", showMessageInput, false);
	//window.addEventListener("get-browser-type", browserMessage, false);
}

function hideMessageInput() {
	console.log('hideMessageInput');
	const chasitorControl = window.document.querySelectorAll('.chasitorControls');
	if(chasitorControl.length > 0){
		chasitorControlsChildren = window.document.querySelectorAll('.chasitorControls')[0].children;
		console.log(chasitorControlsChildren);
		Array.from(chasitorControlsChildren).forEach((element) => {
			element.style.display = 'none';
		});
		const newDiv = document.createElement("div");

		// and give it some content
		const newContent = document.createTextNode("Please select from a menu item above");

		// add the text node to the newly created div
		newDiv.appendChild(newContent);

		window.document.querySelectorAll('.chasitorControls')[0].appendChild(newDiv);
		window.document.querySelectorAll('.chasitorControls')[0].style = 'display: flex;justify-content: center;align-content: center;text-align: center;flex-direction: column-reverse;text-align: left;color: #3a3a3a;background-color: #ededed;';
	}
}

function showMessageInput() {
	console.log('showMessageInput');
	const chasitorControl = window.document.querySelectorAll('.chasitorControls');
	if(chasitorControl.length > 0){
		console.log('found chasitorControl');
		console.log(chasitorControlsChildren);
		window.document.querySelectorAll('.chasitorControls')[0].style = '';
		Array.from(chasitorControlsChildren).forEach((element, index) => {
			if(element.tagName == 'DIV'){
				element.style.display = 'none';
			} else {
				element.style.display = 'flex';
			}
		});
	}
}