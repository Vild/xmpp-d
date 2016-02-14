module xmppd.internal.tcpsslsocket;

import std.socket;
import deimos.openssl.ssl;

static this() {
	SSL_library_init();
	OpenSSL_add_all_algorithms();
	SSL_load_error_strings();
}

class TcpSSLSocket : TcpSocket {
public:
	this(TcpSocket socket) {
		this.socket = socket;
		initTLS();
	}

	~this() {
		SSL_free(ssl);
		SSL_CTX_free(ctx);
	}

	@trusted
	override ptrdiff_t send(const(void)[] buf, SocketFlags flags) {
		return SSL_write(ssl, buf.ptr, cast(uint) buf.length);
	}

	@safe
	override ptrdiff_t send(const(void)[] buf) {
		return send(buf, SocketFlags.NONE);
	}

	@trusted
	override ptrdiff_t receive(void[] buf, SocketFlags flags) {
		return SSL_read(ssl, buf.ptr, cast(int)buf.length);
	}

	@safe
	override ptrdiff_t receive(void[] buf) {
		return receive(buf, SocketFlags.NONE);
	}

	@property TcpSocket Socket() { return socket; }

private:
	TcpSocket socket;
	SSL * ssl;
	SSL_CTX * ctx;

	void initTLS() {
		ctx = SSL_CTX_new(SSLv23_client_method());
		assert(ctx !is null);

		SSL_CTX_set_client_cert_cb(ctx, null);
		SSL_CTX_set_mode(ctx, SSL_MODE_ENABLE_PARTIAL_WRITE);
		SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, null);

		ssl = SSL_new(ctx);
		SSL_set_fd(ssl, socket.handle);
	}
}
