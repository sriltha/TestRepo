package com.example.convert;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class JsonDependencies {
    private String gradleVersion;
    private String generationDate;
    private Project project;
}
