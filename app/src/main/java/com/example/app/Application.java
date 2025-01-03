package com.example.app;

import org.springframework.context.ApplicationListener;
import org.springframework.boot.web.context.WebServerInitializedEvent;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.beans.factory.annotation.Autowired;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SpringBootApplication
public class Application implements ApplicationListener<WebServerInitializedEvent> {

    @Autowired
    private PortService portService;@Override

    public void onApplicationEvent(WebServerInitializedEvent event) {
        Integer port = event.getWebServer().getPort();
        portService.setPort(port);
    }

    public static void main(String[] args) {
        Logger logger = LoggerFactory.getLogger(Application.class);

        String port = System.getenv("PORT");
        if(port == null) {
            port = "8080";
        }
        logger.info("Listening port: " + port);
        System.setProperty("server.port", port);

        SpringApplication.run(Application.class, args);
    }
}
