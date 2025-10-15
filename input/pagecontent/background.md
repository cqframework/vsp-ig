### Background

This implementation guide describes Value Set Packages as a way to streamline implementer access to the terminologies needed for published FHIR implementation guides using an existing open source project called the Value Set Manager.

The "Value Set Manager" is a project funded as part of a cooperative agreement between the Association of Public Health Laboratories and the Centers for Disease Control and Prevention. The project is focused on supporting maintenance and distribution of value sets used in public health case reporting, as described in the [electronic Case Reporting (eCR) implementation guide](https://hl7.org/fhir/us/ecr/electronic_reporting_and_surveillance_distribution_ersd_transaction_and_profiles.html). A significant challenge of the case reporting use case is the management of a large collection of value sets that reference multiple code systems that are all on different publication cycles. The Value Set Manager was specifically developed in recognition of the fact that these same challenges arise anywhere large collections of value sets are managed, including:

* Annual Update for electronic Clinical Quality Measures (eCQMs)
* Value Sets referenced by C-CDA documents
* Value Sets referenced by US-Core

In general, any collection of artifacts that reference value sets will in general have this challenge, and in particular, most FHIR Implementation Guides have this challenge to at least some degree. As the Value Set Manager has progressed alongside the specifications for these use cases, the [Canonical Resource Management Infrastructure (CRMI) implementation guide]({{site.data.fhir.ver.crmi}}) has been developed to provide a way to address this challenge, both in a repository setting (i.e. an ecosystem with API-based access to knowledge artifacts), as well as a package-based setting (i.e. the current FHIR packages ecosystem that supports authoring, packaging, and distribution of FHIR artifacts).

#### Value Set Manager
 
The Value Set Manager is an implementation of the CRMI Artifact Repository (Artifact Repository Service - Canonical Resource Management Infrastructure Implementation Guide v1.0.0 ) and relies on capabilities provided by a [CRMI Artifact Terminology Service]({{site.data.fhir.ver.crmi}}/artifact-terminology-service.html).
 
Specifically, the Value Set Manager currently supports:

* Authoring a Reporting Specification, which is a collection of Grouping Value Sets (i.e. value sets that consist only of references to other value sets) modeled as a FHIR Library resource.
* Authoring the Grouping Value Sets (i.e. maintaining the set of value sets that are part of each grouping value sets)
* Managing the "Input Manifest" for the reporting specification (i.e. the code system versions to be used to expand value sets in the reporting specification)
* "Releasing" a Reporting Specification (i.e. establishing the versions of any versionless canonical references used throughout the specification, also called "pinning") to create an "Output Manifest" that catalogs all the dependencies and their versions of any artifacts in the Reporting Specification, recursively.
* "Packaging" a Reporting Specification (i.e. producing a package containing all the expansions of value sets in the Reporting Specification, expanded according to the versions established in the manifest.
* "Comparing" two different Reporting Specifications (either two different versions of the same Reporting Specification, or different Reporting Specifications) to understand differences in the artifacts that are referenced, down to differences in the expansions.

This feature list is not exhaustive, it just provides an overview of the main features relevant for supporting User-Friendly Value Set Packages. These features correspond to operations described in the CRMI IG, and both the eCR Reporting Specification and eCQM Measure Release Specification use cases have provided feedback to and are implementations of the CRMI implementation guide.

##### eCR Reporting Specification Use Case

In its current form, the Value Set Manager is used by the team that maintains the eCR Reporting Specification. This specification mainly consists of a set of grouping value sets that identify the codes associated with different areas of an EHR information model and that indicate a potentially reportable event (referred to as "triggering codes"). For example, there is a Grouping Value Set for Diagnosis Codes, that includes value sets, organized by rule, that contain codes that would be expected to be found in diagnosis elements such as Problem List Items and Encounter Diagnoses. Another grouping value set includes value sets that contain codes that would be expected to be found in Lab Results. 

Each of these grouping value sets references potentially hundreds of individual value sets that are maintained by public health reporting rule authors (the Council of State and Territorial Epidemiologists, CSTE). These individual value sets are maintained using the Value Set Authority Center directly, and the Value Set Manager is not intended to replace that aspect.

These triggering value sets are currently updated on a six-month cycle. Once the value sets are updated in VSAC with any changes from rules, the Value Set Manager is used to specify updated code system versions. A QA process involving comparison of the previous release to the proposed new release is performed to ensure the content is correct. The Value Set Manager can then be used to create a Release, capturing all the latest value set versions used within the Reporting Specification. Once a Release is available, the Value Set Manager can be used to create a Package, a bundle containing all the expanded value sets based on the versions of code systems and value sets identified by the release specification. Note that we were scheduled for side-by-side production testing of the Value Set Manager for the July content release, however funding issues have prevented that side-by-side use from being completed.

##### eCQM Release Use Case

In addition to the eCR Use Case, the Value Set Manager is being used as part of FHIR-based Quality Reporting to create a manifest that supports predictable expansion of value sets used by quality measures. In this use case, eCQMs reference hundreds of value sets that are maintained by measure developers in the VSAC and used to identify clinical concepts used in quality measurement. These measures are maintained and released on a yearly basis, a process referred to as the Annual Update.

Throughout this process, value sets are updated in response to updates to measure specifications, as well as to support the development of new measure specifications. Once the measures are complete, the Value Set Manager is used to create a Manifest Library whose components are the measure specifications, and that has as input the code system versions to be used to expand value sets referenced by the measures. The Value Set Manager is then used to create a Release, which captures the latest versions of any value sets referenced by the measures. Once a release is available, the Value Set Manager can be used to create a Package, a bundle containing all the expanded value sets based on the versions of code systems and value sets identified by the release specification.

This capability of the Value Set Manager has been demonstrated at the last several connectathons, including the most recent CMS connectathon.

### Alignment to FHIR Terminology Ecosystem IG

The CRMI IG Artifact Terminology Service is based on the FHIR Terminology Service defined in the base FHIR specification (i.e. a CRMI Artifact Terminology Service is also a FHIR Terminology Service). In addition, the intent of CRMI Artifact Terminology Service is to align with the [FHIR Terminology Ecosystem IG](https://hl7.org/fhir/uv/tx-ecosystem/), and part of the initial ballot and publication of CRMI was alignment with the ecosystem IG. While it is not necessarily the case that all CRMI terminology services need to be ecosystem servers, nor vice versa, it is certainly the case that there should be nothing that a CRMI terminology service requires that is inconsistent with terminology management as described in the terminology ecosystem. And in particular, the capabilities enabled by the ecosystem, such as authoritative servers for code systems, will be important for CRMI terminology services.