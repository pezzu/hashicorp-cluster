package com.example.app;

import org.springframework.context.ApplicationListener;
import org.springframework.boot.web.context.WebServerInitializedEvent;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.beans.factory.annotation.Autowired;

@SpringBootApplication
public class Application implements ApplicationListener<WebServerInitializedEvent> {


    @Autowired
    private PortService portService;@Override

    public void onApplicationEvent(WebServerInitializedEvent event) {
        Integer port = event.getWebServer().getPort();
        portService.setPort(port);
    }

    public static void main(String[] args) {
        String port = System.getenv("PORT");
        if(port == null) {
            port = "8080";
        }
        System.setProperty("server.port", port);

        SpringApplication.run(Application.class, args);
    }
}
