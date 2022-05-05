package com.example.demo;

import com.example.convert.Configuration;
import com.example.convert.Dependency;
import com.example.convert.JsonDependencies;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) throws IOException {

        SpringApplication.run(DemoApplication.class, args);
        String content = new String(Files.readAllBytes(Paths.get("C:\\Users\\adepu\\Downloads\\demo\\build\\reports\\project\\dependencies\\root.js")));
        String json = content.substring(29);
        json = json.substring(0, json.length() - 1);
        //System.out.println(json);
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        JsonDependencies jsonDependencies = objectMapper.readValue(json, JsonDependencies.class);
        System.out.println("****************************");
        System.out.println("****************************");
        Set<String> set = new HashSet<String>();

        List<Configuration> configurations = jsonDependencies.getProject().getConfigurations();
        for (Configuration configuration : configurations) {
            for (Dependency dependency : configuration.getDependencies()) {
                for (Dependency children : dependency.getChildren()) {
                    if (!children.isHasConflict()) {
                        for (Dependency child : children.getChildren()) {
                            if (!child.isHasConflict()) {
                                //System.out.println(child.getName());
                                set.add(child.getName());
                            }
                        }
                    }

                }
            }

        }
        set.stream().forEach(System.out::println);

    }

}
