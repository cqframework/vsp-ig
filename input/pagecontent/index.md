### Introduction

This implementation guide provides documentation and demonstration artifacts for Value Set Packages to enable IG/Publication authors and implementers to define and distribute updated terminology for any IG/Publication on a predictable basis. 

Two primary use cases are documented:

1. Enable authors to define Value Set Packages that identify code system versions to be used to expand value sets used in the implementation guide. 
2. Enable implementers to obtain Value Set Packages containing "refreshed" value sets expanded with the specified code system versions. 

This capability will be provided through the use of the Value Set Manager, an existing open source implementation of the Canonical Resource Management Infrastructure (CRMI) IG that is being used to manage public health triggering value sets, as well as FHIR-based quality measure value sets.

### Overview

A _Value Set Package_ is all the expanded value sets required for an implementation guide, refreshed using specified code system versions, so that implementers can obtain stable, predictable expansions that are consistent with author intent.

Value Set Packages are defined by IG/Publication authors as needed. For example, the US Core 6.1.0 Implementation Guide was initially published in June of 2023.

### Dependencies

{% include dependency-table-short.xhtml %}

### Cross Version Analysis

{% include cross-version-analysis.xhtml %}

### Global Profiles

{% include globals-table.xhtml %}

### IP Statements

{% include ip-statements.xhtml %}
