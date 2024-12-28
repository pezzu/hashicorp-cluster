package com.example.app;

import org.springframework.stereotype.Component;

@Component
public class PortService {
    private Integer port;

    public Integer getPort() {
        return port;
    }

    public void setPort(Integer port) {
        this.port = port;
    }
}
