import std.stdio;

import xmppd.xmppclient;

void main() {
	XMPPClient c = new XMPPClient("livecoding.tv", "wildbot@livecoding.tv", "");
	c.Connect();
}
