# Storage Requirements Assessment for CRMI-Based FHIR IG Package Service

## Overview

This document provides a refined storage estimate for a service responsible for generating and storing CRMI-based packages for FHIR Implementation Guides (IGs).

Considerations:
- Retention-based modeling (3 versions per IG)
- Growth modeling (1 release per IG per year)
- Jurisdiction-based sizing (e.g., US-only vs global)

---

## Scope Assumptions

- 914 latest R4 IG packages
- ~5,700 total historical versions (not used for retained model)
- Retention policy: **3 versions per IG**
- Growth: **1 new version per IG per year**
- Worst-case package size: **200 MB**
- VSAC-scale packages excluded

---

## Global Storage Estimates (R4)

### Retained Versions
914 IGs × 3 versions = **2,742 package versions**

### Storage Estimates

| Avg Size | Total Storage |
|----------|-------------|
| 25 MB | ~68.6 GB |
| 50 MB | ~137.1 GB |
| 100 MB | ~274.2 GB |
| 200 MB (worst-case) | ~548.4 GB |

### Annual Growth

| Avg Size | Annual Growth |
|----------|--------------|
| 25 MB | ~22.9 GB |
| 50 MB | ~45.7 GB |
| 100 MB | ~91.4 GB |
| 200 MB | ~182.8 GB |

---

## Jurisdiction-Based Estimates (US Example)

### Dataset

- 119 US R4 IGs
- Retained versions: 119 × 3 = **357**

### Storage Estimates

| Avg Size | Total Storage |
|----------|-------------|
| 25 MB | ~8.9 GB |
| 50 MB | ~17.9 GB |
| 100 MB | ~35.7 GB |
| 200 MB (worst-case) | ~71.4 GB |

### Annual Growth

| Avg Size | Annual Growth |
|----------|--------------|
| 25 MB | ~3.0 GB |
| 50 MB | ~6.0 GB |
| 100 MB | ~11.9 GB |
| 200 MB | ~23.8 GB |

---

## Key Insight

Jurisdiction significantly impacts storage:

- US-only ≈ **13% of global footprint**
- Enables smaller, targeted deployments

---

## Final Recommendations

### Global Deployment
- Likely: **140–275 GB**
- Conservative: **~500 GB**
- With operational overhead: **500 GB – 1 TB**

### US-only Deployment
- Likely: **18–36 GB**
- Conservative: **~70 GB**
- With operational overhead: **100–200 GB**

---

## Bottom Line

- Storage requirements scale with:
  - IG count
  - retained versions
  - package size
- Jurisdiction filtering is a major lever for reducing footprint

