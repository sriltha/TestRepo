package com.example.convert;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Configuration {
    private String name;
    private String description;
    private List<Dependency> dependencies;
    private List<ModuleInsight> moduleInsights;

}
