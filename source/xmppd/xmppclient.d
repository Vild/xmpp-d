module xmppd.xmppclient;

import std.socket;
import std.conv;

import xmppd.internal.tcpsslsocket;

import kxml.xml;

final class XMPPClient {
public:
	this(string address, string jid, string pass, ushort port = 5222, string resource = "xmpp-d") {
		this.address = address;
		this.jid = jid;
		this.pass = pass;
		this.port = port;
		this.resource = resource;
	}

	~this() {
		Disconnect();
	}

	void Connect() {
		import std.stdio;
		string hello = "<?xml version=\"1.0\"?><stream:stream to=\"livecoding.tv\" xmlns=\"jabber:client\" xmlns:stream=\"http://etherx.jabber.org/streams\" version=\"1.0\" xml:lang=\"en\">";

		socket = new TcpSocket(new InternetAddress(address, port));
		socket.send(hello.ptr[0 .. hello.length]);


		ubyte[512] data;
		ptrdiff_t len;
		len = socket.receive(data);
		if (len == Socket.ERROR || len == 0)
			return;
		string firstMsg = (cast(char[])data[0 .. len]).to!string;
		firstMsg ~="</stream:stream>";
		XmlNode node = firstMsg.readDocument;

		string id = node.getChildren()[1].getAttribute("id");
		writeln("Connection id is: ", id);

		len = socket.receive(data);
		while (len != Socket.ERROR && len != 0) {
			string msg = (cast(char[])data[0 .. len]).to!string;
			XmlNode xml = msg.readDocument;
			writeln(xml.toString);

			if (xml.getChildren[0].getName() == "stream:features" && xml.getChildren[0].getChildren[0].getName() == "starttls") {
				socket.send("<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>");
			} else if (xml.getChildren[0].getName == "proceed") {
				socket = new TcpSSLSocket(socket);
				/*socket.send("<stream:stream from='wildbot@livecoding.tv' to='livecoding.tv' version='1.0' xml:lang='en' xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams'>", SocketFlags.NONE);*/
			}

			len = socket.receive(data);
		}

		writeln("Socket connection is: len: ", len, " isDead: ", len == Socket.ERROR);
	}

	void Disconnect() {

	}

private:
	string address;
	string jid;
	string pass;
	ushort port;
	string resource;

	TcpSocket socket;
}
