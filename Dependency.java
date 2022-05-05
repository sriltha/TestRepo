package com.example.convert;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Dependency {
    private String module;
    private String name;
    private String resolvable;
    private boolean hasConflict;
    private boolean alreadyRendered;
    private List<Dependency> children;
}
