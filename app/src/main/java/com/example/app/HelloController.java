package com.example.app;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.http.HttpStatus;

import java.net.InetAddress;
import java.net.UnknownHostException;

@RestController
public class HelloController {

    private final PortService portService;

    public HelloController(PortService portService) {
        this.portService = portService;
    }

    @GetMapping("/")
    public String sayHello() {
        return "Hello";
    }

    @GetMapping("/version")
    public String getVersion() {
        return "app verison is " + getClass().getPackage().getImplementationVersion();
    }

    @GetMapping("/server-info")
    public String getServerInfo() throws UnknownHostException {
        String hostname = InetAddress.getLocalHost().getHostName();

        return "app address is " + hostname + ":" + portService.getPort();
    }

    @GetMapping("/healthz")
    @ResponseStatus(HttpStatus.OK)
    public void healthz() {
    }
}
