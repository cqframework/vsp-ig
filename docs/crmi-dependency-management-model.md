# CRMI Dependency Management Model

This document defines the **dependency management model** for use in the **Canonical Resource Management Infrastructure (CRMI)** implementation guide and supporting operations (notably `$release` and `$package`).  

This incorporates the following:
- We identify `packageOnly` as the recursion toggle.
- We add `excludePackageId` to filter out dependencies from specific packages (e.g. FHIR core, THO).
- We rely on the standard `package-source` extension (`http://hl7.org/fhir/StructureDefinition/package-source`) to record provenance for each dependency, and we extend its allowed context to include `RelatedArtifact` elements.

---

## 1. Overview

The CRMI dependency model describes how artifacts relate to one another across **release** and **packaging** workflows.

- `$release` performs a **complete recursive dependency walk**, discovers all related artifacts, and records why they're needed and (when possible) where they came from.
- `$package` filters those dependencies into a transaction bundle based on caller intent.

Each dependency may carry:
- A **role** (why it matters).
- A **package-source** (where it came from).
- A **referenceSource** (where in the source artifact it was discovered).
- The resource type.

| Concept | Purpose |
|---------|---------|
| **Dependency Role** (`crmi-dependencyRole`) | Describes *why* the dependency exists (key/default/example/test). |
| **package-source** (`http://hl7.org/fhir/StructureDefinition/package-source`) | Identifies package supplied the artifact. |
| **referenceSource** (`http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-referenceSource`) | Identifies the artifact & element/path where the dependency was referenced. |
| **excludePackageId** (parameter to `$package`) | Lets clients say "don't include anything from package X." |

---

## 2. Dependency Role

### Extension
**URL:** `http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-dependencyRole`  
**Context:** `RelatedArtifact` (type = `depends-on`)  
**Type:** `code` (0..*)  
**Binding (required):**

| Code | Meaning |
|------|---------|
| `key` | Required to implement or interpret *key elements* of the artifact. |
| `default` | General supporting dependency not directly tied to key elements. |
| `example` | Used only for examples / demonstrative content. |
| `test` | Used only for test/conformance/validation scenarios. |

### Rules
- A dependency may have multiple roles (e.g. `key` + `test`).
- Roles propagate recursively: If a profile's key element binds to a ValueSet, and that ValueSet uses a CodeSystem, both the ValueSet and that CodeSystem qualify as `key`.
- If no role is recorded, treat it as `default`.

This gives `$package` a clean way to do things like:
- "Give me only the stuff I need to implement" → `include=key`
- "Don't include test decks and examples" → `exclude=test&exclude=example`

---

## 3. Source Package Provenance

### Extension
**URL:** `http://hl7.org/fhir/StructureDefinition/package-source`  
**Context:**  
- Originally used on IG-published artifacts to indicate which FHIR package they came from.  
- Extended context: also allowed on each `RelatedArtifact` (type = `depends-on`) in the release manifest.

### Type
`string` (0..1)

### Example value
- `"hl7.fhir.us.core#6.1.0"`  
- `"hl7.fhir.r4.core#4.0.1"`  
- `"hl7.terminology#6.0.0"`  

### Purpose
Declares: A dependency originated from package `<id>#<version>`. 
Allows `$package` to determine whether a dependency should be excluded based on `excludePackageId`.

### Population Rules (in `$release`)
1. When `$release` can determine the package of a dependency, it SHOULD populate `package-source`.
   - Derived from `package.json` for imported packages.
   - Derived from `ImplementationGuide.packageId` when available.
2. If the package ID is known but version is not, record just the package ID.
3. If unknown, omit `package-source`.

---

## 4. Reference Source

### Extension  
**URL:** `http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-referenceSource`  
**Context:** `RelatedArtifact` (type = `depends-on`)  
**Type:** complex extension with nested `artifact` and `path` children.

The `crmi-referenceSource` extension captures *where* in the originating artifact a dependency was discovered.

- `artifact` — Canonical URL of the artifact containing the reference.  
- `path` — A FHIRPath-based expression or element path locating the exact reference.

**Example**

```json
{
  "extension" : [
    {
      "url" : "artifact",
      "valueCanonical" : "http://hl7.org/fhir/uv/crmi/StructureDefinition/publishable-example"
    },
    {
      "url" : "path",
      "valueString" : "differential.element.where(id='Observation.value[x]').binding.valueSet"
    }
  ],
  "url" : "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-referenceSource"
}
```

### Population Rules (in `$release`)
- `$release` SHOULD populate this extension whenever a dependency is discovered during the dependency walk.  
- Multiple occurrences MAY be recorded when the same dependency appears in more than one place.  
- Extensions MUST be attached to the `RelatedArtifact` representing the dependency.

---

## 5. `$release` Responsibilities

During `$release`, the server SHALL:

1. Perform a **full recursive dependency walk**, including:
   - Components of the released artifact.
   - Key-element-driven dependencies.
   - Required terminology (ValueSets, CodeSystems), even from terminology servers.
   - Example/test artifacts.
   - Parent or related implementation guide dependencies.

2. For each discovered dependency:
   - Create or merge a `RelatedArtifact` (`type = depends-on`).
   - Annotate it with:
     - `crmi-dependencyRole` (0..*)
     - `package-source` (0..1, if determinable)
     - `crmi-referenceSource` (0..*, where the dependency was found)
     - `cqf-resourceType` (existing extension)

3. If duplicates are found by canonical:
   - Merge `crmi-dependencyRole` values.
   - Prefer the most specific `package-source` (with version if possible).

Result: a manifest (typically a CRMI Manifest Library) that is both **complete** and **annotated** with role and provenance.

---

## 6. `$package` Responsibilities

`$package` produces an installable FHIR package by filtering dependencies in the released manifest.

### Parameters
| Parameter | Type | Description |
|------------|------|-------------|
| `packageOnly` | `boolean` | Controls whether recursion occurs. |
| `excludePackageId` | `string` (0..*) | Excludes dependencies that originate from listed packages. |
| `include` / `exclude` | `code` (0..*) | Filters by role (`key`, `example`, `test`) or category (`profiles`, `terminology`, etc.). |

### Semantics
| Behavior | Description |
|-----------|-------------|
| `packageOnly=true` | Package only the artifact and its owned components. |
| `packageOnly=false` | Include dependencies recursively. |
| `excludePackageId` | Exclude dependencies from listed package IDs. |

### Provenance Resolution (for `excludePackageId`)

When applying `excludePackageId`, `$package` determines source package using the following precedence:

1. **Declared `package-source` extension** - authoritative.  
2. **Local `package.json`** - derive packageId/version if the dependency was imported locally.  
3. **Cached `package-list.json`** - map canonical prefix to packageId (e.g. `http://hl7.org/fhir/uv/crmi` -> `hl7.fhir.uv.crmi`).  
4. **ImplementationGuide inference** - use `ImplementationGuide.packageId` or infer from IG URL.  
5. **Static HL7 mappings** 
   - `http://hl7.org/fhir/` -> `hl7.fhir.rX.core`  
   - `http://terminology.hl7.org/` -> `hl7.terminology`  
   - `http://hl7.org/fhir/extensions/` -> `hl7.fhir.extensions.rX`  

If no package can be identified, the dependency is **not excluded** (to prevent accidental data loss).

---

## 7. Example Manifest Fragment

```json
{
  "relatedArtifact": [{
    "type": "depends-on",
    "resource": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-condition",
    "extension": [
      {
        "url": "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-dependencyRole",
        "valueCode": "key"
      },
      {
        "url": "http://hl7.org/fhir/StructureDefinition/package-source",
        "valueString": "hl7.fhir.us.core#6.1.0"
      },
      {
        "url": "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-referenceSource",
        "extension": [
          {
            "url": "artifact",
            "valueCanonical": "http://hl7.org/fhir/uv/crmi/StructureDefinition/publishable-example"
          },
          {
            "url": "path",
            "valueString": "differential.element.where(id='Observation.value[x]').binding.valueSet"
          }
        ]
      },
      {
        "url": "http://hl7.org/fhir/uv/crmi/StructureDefinition/cqf-resourceType",
        "valueCode": "StructureDefinition"
      }
    ]
  }]
}
```

---

## 8. Typical Usage Patterns

| Mode | Description | Example Parameters |
|------|-------------|--------------------|
| **Local only** | Only package the root artifact and its owned components. | `packageOnly=true` |
| **Recursive (exclude core)** | Recursively include dependencies but exclude FHIR Core + THO. | `packageOnly=false&excludePackageId=hl7.fhir.r4.core&excludePackageId=hl7.terminology` |
| **Fully recursive** | Include all dependencies (core + THO). | `packageOnly=false` |
| **Production bundle** | Filter out test/example content and core packages. | `packageOnly=false&excludePackageId=hl7.fhir.r4.core&excludePackageId=hl7.terminology&exclude=example&exclude=test` |
| **Conformance bundle** | Include test artifacts for validation. | `packageOnly=false&include=test` |

---

## 9. Summary Diagram

```
┌────────────────────────────────────────────────────────┐
│                       $release                         │
│────────────────────────────────────────────────────────│
│  • Builds full dependency graph                        │
│  • Records:                                            │
│      - crmi-dependencyRole                             │
│      - package-source                                  │
│      - crmi-referenceSource                            │
│  • Produces manifest (CRMI Manifest Library)           │
└────────────────────────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│                       $package                         │
│────────────────────────────────────────────────────────│
│  • Reads manifest                                      │
│  • Filters by:                                         │
│      - packageOnly (recursion)                         │
│      - excludePackageId (source package)               │
│      - include/exclude (roles, categories)             │
│  • Outputs curated Bundle                              │
└────────────────────────────────────────────────────────┘
```

---

## 10. Key Takeaways

| Concept | Description |
|----------|-------------|
| `packageOnly` | Toggles recursion. |
| `excludePackageId` | Removes dependencies from specified packages. |
| `crmi-dependencyRole` | Explains *why* a dependency exists. |
| `package-source` | Standard FHIR extension (extended for `RelatedArtifact`) to record provenance. |
| `crmi-referenceSource` | Captures where in the source artifact a dependency originated. |
| Fallback logic | If no provenance known, `$package` does **not** exclude. |
| Safety model | Always errs on side of including too much rather than too little. |

**In short:**  
> `$release` annotates dependencies with role and package provenance; `$package` filters by recursion, package ID, and purpose.
