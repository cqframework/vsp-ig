### Introduction

This implementation guide provides documentation and demonstration artifacts for Value Set Packages to enable IG/Publication authors and implementers to define and distribute updated terminology for any IG/Publication on a predictable basis. 

Two primary use cases are documented:

1. Enable authors to define Value Set Packages that identify code system versions to be used to expand value sets used in the implementation guide. 
2. Enable implementers to obtain Value Set Packages containing "refreshed" value sets expanded with the specified code system versions. 

This capability will be provided through the use of the Value Set Manager, an existing open source implementation of the Canonical Resource Management Infrastructure (CRMI) IG that is being used to manage public health triggering value sets, as well as FHIR-based quality measure value sets.

### Overview

A _Value Set Package_ is all the expanded value sets required for an implementation guide, refreshed using specified code system versions, so that implementers can obtain stable, predictable expansions that are consistent with author intent.

Value Set Packages are defined by IG/Publication authors as needed. For example, the US Core 6.1.0 Implementation Guide was initially published in June of 2023. At that time, some of the code system versions available were:

US Core 6.1.0 Initial Publication
* SNOMED, US Edition, 2023-03
* LOINC, 2.74, 2023-03
* RxNorm, 05012023, 2023-05

Since that time, many of the code systems used by value sets in the implementation guide have been updated, including at least SNOMED, LOINC, and RxNORM. 

A _Value Set Package Definition_ is used to specify the code system versions (i.e. input expansion parameters) to be used. For example:

US Core 6.1.0 2025 Refresh
* SNOMED, US Edition, 2025-03
* LOINC 2.80, 2025-04
* RXNORM 08042025, 2025-08
* ...

This Value Set Package Definition is then _released_, a process that involves _pinning_ all the dependencies used by the implementation guide. If the version of a dependency is not set by the input expansion parameters, then the latest known version is recorded.

With the released Value Set Package Definition, the Value Set Package can be _packaged_ by using a terminology server to expand all the value sets using the code system versions specified in the released definition. These expanded value sets can then be provided as a Bundle.

### Contents

* **[Background](background.html)**
* **[Specification](specification.html)**
* **[Examples](examples.html)**
* **[Artifacts](artifacts.html)**
* **[Changes](changes.html)**

### Dependencies

{% include dependency-table-short.xhtml %}

### Cross Version Analysis

{% include cross-version-analysis.xhtml %}

### Global Profiles

{% include globals-table.xhtml %}

### IP Statements

{% include ip-statements.xhtml %}
