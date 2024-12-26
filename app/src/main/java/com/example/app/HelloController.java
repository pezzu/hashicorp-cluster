package com.example.app;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    // This method will respond to GET requests at "/hello"
    @GetMapping("/")
    public String sayHello() {
        return "Hello";
    }
}
