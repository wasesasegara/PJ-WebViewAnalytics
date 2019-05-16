//
//  WebViewJavaScriptSource.swift
//  PJ WebViewAnalytics
//
//  Created by Bisma S Wasesasegara on 5/16/19.
//  Copyright © 2019 Bisma S Wasesasegara. All rights reserved.
//

let webViewJavaScriptSource: String = """
function logEvent(name, params) {
if (!name) {
return;
}

if (window.AnalyticsWebInterface) {
// Call Android interface
window.AnalyticsWebInterface.logEvent(name, JSON.stringify(params));
} else if (window.webkit
&& window.webkit.messageHandlers
&& window.webkit.messageHandlers.firebase) {
// Call iOS interface
var message = {
command: 'logEvent',
name: name,
parameters: params
};
window.webkit.messageHandlers.firebase.postMessage(message);
} else {
// No Android or iOS interface found
console.log("No native APIs found.");
}
}

function setUserProperty(name, value) {
if (!name || !value) {
return;
}

if (window.AnalyticsWebInterface) {
// Call Android interface
window.AnalyticsWebInterface.setUserProperty(name, value);
} else if (window.webkit
&& window.webkit.messageHandlers
&& window.webkit.messageHandlers.firebase) {
// Call iOS interface
var message = {
command: 'setUserProperty',
name: name,
value: value
};
window.webkit.messageHandlers.firebase.postMessage(message);
} else {
// No Android or iOS interface found
console.log("No native APIs found.");
}
}
"""
