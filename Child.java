package com.example.convert;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Child {
    private String name;
    private String resolvable;
    private boolean hasConflict;
    private boolean alreadyRendered;
    private boolean isLeaf;
    private Child[] children;
}
