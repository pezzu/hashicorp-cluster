package com.example.app;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.http.HttpStatus;

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.io.File;
import java.io.IOException;
import java.net.InetAddress;
import java.net.URISyntaxException;
import java.net.UnknownHostException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/app")
public class HelloController {

    private final PortService portService;

    public HelloController(PortService portService) {
        this.portService = portService;
    }

    @GetMapping("/")
    public String sayHello() {
        return "Hello from App\n";
    }

    @GetMapping("/version")
    public Map<String, String> getVersion() {
        return Map.of("version", getClass().getPackage().getImplementationVersion());
    }

    @GetMapping("/server-info")
    public Map<String, String> getServerInfo() throws UnknownHostException {
        String hostname = InetAddress.getLocalHost().getHostName();

        return Map.of("hostname", hostname + ":" + portService.getPort());
    }

    @GetMapping("/params")
    public Map<String, Object> getParams() throws URISyntaxException{
        Path paramsPath = Paths.get(getClass().getProtectionDomain().getPermissions().elements().nextElement().getName()).getParent();

        try {
            List<String> params = Files.readAllLines(paramsPath.resolve("params.txt"));
            Map<String, Object> result = new HashMap<>();
            for (String param : params) {
                String[] parts = param.split(":");
                result.put(parts[0], parts[1]);
            }
            return result;
        }
        catch (IOException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "params.txt not found");
            return error;
        }
    }

    @GetMapping("/healthz")
    @ResponseStatus(HttpStatus.OK)
    public Map<String, String> healthz() {
        return Map.of("status", "ok");
    }
}
