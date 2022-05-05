package com.example.convert;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Insight {
    private String name;
    private String description;
    private String resolvable;
    private boolean hasConflict;
    private List<Child> children;
}
