package com.edlearn.backend.config;

import javax.net.SocketFactory;
import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketAddress;

public class NeonSocketFactory extends SocketFactory {

    private static final String TARGET_IP = "52.76.212.156";

    public static class NeonSocket extends Socket {
        public NeonSocket() {
            super();
        }

        @Override
        public void connect(SocketAddress endpoint, int timeout) throws IOException {
            int port = 5432;
            if (endpoint instanceof InetSocketAddress) {
                port = ((InetSocketAddress) endpoint).getPort();
            }
            super.connect(new InetSocketAddress(TARGET_IP, port), timeout);
        }
    }

    public NeonSocketFactory() {}

    public NeonSocketFactory(String arg) {}

    @Override
    public Socket createSocket() throws IOException {
        return new NeonSocket();
    }

    @Override
    public Socket createSocket(String host, int port) throws IOException {
        Socket s = new NeonSocket();
        s.connect(new InetSocketAddress(TARGET_IP, port), 10000);
        return s;
    }

    @Override
    public Socket createSocket(String host, int port, InetAddress localHost, int localPort) throws IOException {
        Socket s = new NeonSocket();
        s.bind(new InetSocketAddress(localHost, localPort));
        s.connect(new InetSocketAddress(TARGET_IP, port), 10000);
        return s;
    }

    @Override
    public Socket createSocket(InetAddress host, int port) throws IOException {
        Socket s = new NeonSocket();
        s.connect(new InetSocketAddress(TARGET_IP, port), 10000);
        return s;
    }

    @Override
    public Socket createSocket(InetAddress address, int port, InetAddress localAddress, int localPort) throws IOException {
        Socket s = new NeonSocket();
        s.bind(new InetSocketAddress(localAddress, localPort));
        s.connect(new InetSocketAddress(TARGET_IP, port), 10000);
        return s;
    }
}
