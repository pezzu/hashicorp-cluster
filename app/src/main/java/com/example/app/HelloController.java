package com.example.app;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String sayHello() {
        return "Hello";
    }

    @GetMapping("/version")
    public String getVersion() {
        return "App verison is " + getClass().getPackage().getImplementationVersion();
    }
}
