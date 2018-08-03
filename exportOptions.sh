#!/bin/bash

exportPlist="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\
<plist version=\"1.0\">\
<dict>\
<key>method</key>\
<string>$2</string>\
<key>signingStyle</key>\
<string>automatic</string>\
<key>stripSwiftSymbols</key>\
<true/>\
<key>teamID</key>\
<string>$1</string>\
<key>uploadBitcode</key>\
<false/>\
<key>uploadSymbols</key>\
<true/>\
</dict>\
</plist>
"
echo $exportPlist > $3/ExportOptions.plist

