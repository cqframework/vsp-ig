### Overview

This topic provides a detailed technical description of the Value Set Packages approach.

### Value Set Packages

Value Set Packages provide implementers with the complete set of expanded value sets used by an implementation guide. Published FHIR packages include ValueSet resources with definitions (i.e. the `compose` element). In addition, because FHIR implementation guides refer to terminology from various sources, including other implementation guides, the base FHIR specification, THO (terminology.hl7.org), and national terminology services (e.g. the Value Set Authorith Center (VSAC) in the U.S.), implementers must gather terminology from multiple sources, as well as ensure that the expansion of those value sets is performed with appropriate versions of the code systems used.

#### Structure

Value Set Packages are ultimately a collection of FHIR ValueSet resources, together with a FHIR Library resource that acts as a _manifest_, describing exactly what value sets the package contains, as well as the versions of terminology dependencies used to build the expansions.

This Value Set Package can be represented as a FHIR Bundle:

```json
{
    "resourceType": "Bundle",
    "entry": [
        { ... Library resource (the Value Set Package definition, or manifest) ... },
        { ... ValueSet resource ... },
        { ... ValueSet resource ... },
        ...
    ]
}
```

The Library resource is the Value Set Package definition, described in the next section, while all the subsequent entries in the Bundle are the ValueSet resources, each one with an `expansion` element containing the full expansion of the value set.

#### Definition

The Value Set Package Definition is a Library resource, structured as follows:

```json
{
    "resourceType": "Library",
    "contained": [
        { ... Parameters resource specifying the versions of dependencies used (i.e. the Manifest Parameters) ... }
    ],
    "extension": [
        { ... cqf-expansionParameters extension referencing the contained Parameters resource ... }
    ]
    // The canonical URL for the Value Set Package. This is not the same URL as the implementation guide, but for
    // ease of use, it should be based on the source implementation guide:
    "url": "http://hl7.org/fhir/us/core-vsp/6.1.0/Library/hl7.fhir.us.core-vsp-6-1-0",
    // The version of the Value Set Package. Value Set Packages are typically periodically refreshed, and so will
    // often make use date-based versioning
    "version": "2024-09",
    ... name, title, status, date, description, etc. ...
    "type": { ..., "display": "Asset Collection" ... },
    "relatedArtifact": [
        { "type": "composed-of", "resource": "http://hl7.org/fhir/us/core/ImplementationGuide/hl7.fhir.us.core|6.1.0" }
    ]
}
```

First, the Value Set Package is identified by the canonical url of the library. Note carefully that this is not the same URL as the implementation guide, but for ease of use, it should be based on the source implementation guide. For example, the US Core 6.1.0 Implementation Guide might have a Value Set Package with a URL of `http://hl7.org/fhir/us/core-vsp/6.1.0/Library/hl7.fhir.us.core-vsp-6-1-0`.

Second, as with any canonical resource, the Value Set Package has a version element that allows multiple versions of this Value Set Package to be produced over time. This is important to support periodically refreshing the value set package. As well, other metadata typically found on canonical resources is provided such as `name`, `title`, `status`, `date`, and so on.

Third, the Value Set Package definition will have a contains Parameters resource, referenced by the `cqf-expansionParameters` extension that specifies the code system dependencies for the value set package.

And finally, the Value Set Package definition will have a `relatedArtifact` entry identifying the Implementation Guide. The `type` of this entry is `composed-of` to indicate that the Asset Collection starts with the implementation guide.

To ensure content expectations are met, a Value Set Package Definition must conform to the [CRMIManifestLibrary]({{site.data.fhir.ver.crmi}}/StructureDefinition-crmi-manifestlibrary.html) profile.

#### Release

Once the Value Set Package Definition is complete, it can be _released_ using the CRMI [$release]({{site.data.fhir.ver.crmi}}/OperationDefinition-release.html) operation, resulting in a released Value Set Package Definition that will have the following additional structure:

```json
{
    "contained": [
        { ... Parameters resource with additional parameters specifying the pinned versions identified by release ... }
        { ... Parameters resource specifying the input parameters used (i.e. the Input Manifest Parameters prior to release) ... }
    ],
    "extension": [
        { ... cqf-inputParameters extension referencing the contained input Parameters resource ... }
    ],
    ...
    "relatedArtifact": [
        { "type": "depends-on", "resource": "... Value Set dependency A ..." },
        { "type": "depends-on", "resource": "... Value Set dependency B ..." },
        ... entries for each dependency, with version resolved
    ]
}
```

#### Package

Once the Value Set Package Definition is released, it can be _packaged_ using the CRMI [$package]({{site.data.fhir.ver.crmi}}/OperationDefinition-package.html) operation, resulting in a Bundle with the following overall structure:

```json
{
    "resourceType": "Bundle",
    "entry": [
        { "resource": { ... a Library resource describing the resulting package ...  } },
        { "resource": { ... ExpandedValueSet A ...  } },
        { "resource": { ... ExpandedValueSet B ...  } },
        ...
    ]
}
```

### Pinning In the Publisher

The FHIR IG publisher has a feature called _canonical pinning_ that provides for a variety of approaches to dealing with dependency versioning. Similar to the _release_ process for value set packages defined here, the publisher will resolve unversioned canonical references as part of publication. The publisher can be configured to record version resolution in a _manifest_ (as opposed to updating the reference in the published resource to be a versioned reference). Configuring implementation guides to make use of this manifest will ensure that the Value Set Packages approach described here can manage version dependencies, rather than having to override them.

To ensure this alignment, this IG recommends that implementation guides be configured as follows:

1. Create a _manifest parameters_ resource
2. Configure pinning to make use of this manifest

#### Create Manifest Parameters

First, create a Parameters resource with an `id` of `manifest`:

```json
{
  "resourceType" : "Parameters",
  "id" : "manifest",
  "parameter" : [{
    "name" : "system-version",
    "valueCanonical" : "http://snomed.info/sct|http://snomed.info/sct/900000000000207008"
  }]
}
```

> Note that this specifies the International Edition of SNOMED. Be sure to select an edition of SNOMED appropriate for your realm. For example, in the US Realm, use `http://snomed.info/sct|http:/snomed.info/sct/731000124108` to specify the US-Edition of SNOMED. For more details on specifying terminology versions, see the [External Code Systems](https://terminology.hl7.org/external_terminologies.html) topic.

Next, include this manifest parameters resource in your implementation guide by either adding it to an existing resources folder, or creating a new `parameters` resource folder. If you create a new `parameters` resource folder, be sure to add that to the resources path for your implementation guide using the [`path-resource`](https://build.fhir.org/ig/FHIR/fhir-tools-ig/CodeSystem-ig-parameters.html#:~:text=path%2Dexpansion%2Dparams) implementation guide parameter:

```xml
<parameter>
    <code value="path-resource" />
    <value value="input/resources/parameters"/>
</parameter>
```

Next, make sure to provide a name and description for this manifest parameters resource in the implementation guide:

```xml
<resource>
    <reference>
        <reference value="Parameters/manifest"/>
    </reference>
    <name value="Input Expansion Parameters"/>
    <description value="The input expansion parameters resource for this implementation guide, specifying SNOMED Edition. This resource will be contained within the published implementation guide with all pinned references."/>
    <exampleBoolean value="false"/>
</resource>
```

Then, configure the implementation guide to use these manifest parameters as the expansion parameters for the publisher using the [`path-expansion-params`](https://build.fhir.org/ig/FHIR/fhir-tools-ig/CodeSystem-ig-parameters.html#:~:text=path%2Dexpansion%2Dparams) implementation guide parameter:

```xml
<parameter>
    <code value="path-expansion-params"/>
    <value value="resources/parameters/Parameters-manifest.json"/>
</parameter>
```

#### Configure Publisher Pinning to use a Manifest

First, set the `pin-canonicals` parameter to `pin-all`:

```xml
<parameter>
    <code value="pin-canonicals"/>
    <value value="pin-all"/>
</parameter>
```

Next, set the `pin-manifest` parameter to the id of the manifest resource (`manifest` in this case):

```xml
<parameter>
    <code value="pin-manifest"/>
    <value value="manifest"/>
</parameter>
```

In addition, consider setting the `pin-external` parameter, as this will instruct the publisher to capture the versions of any external code systems encountered during pinning. This information is useful for downstream consumers of the implementation guide to understand exactly what dependencies were used when validating and releasing the content of the implementation guide:

```xml
<parameter>
    <code value="pin-external"/>
    <value value="true"/>
</parameter>
```

Following these recommendations ensures that resources published in implementation guides do not pin references to canonical resources, so that these references can be redirected using the value set package definitions.

See the [Canonical Pinning](https://build.fhir.org/ig/FHIR/ig-guidance/pinning.html#managing-canonical-versions-pinning) topic in FHIR IG Guidance for a detailed description of how pinning works in the publisher.