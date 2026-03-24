### Overview

Value Set Packages provide a simple way for implementers to obtain all the terminology required to support implementation of any published implementation guide. This application will work with any FHIR Implementation Guide available in the [FHIR Package Registry](https://registry.fhir.org/).

A _value set package_ is:

* Complete expansions of all the value sets in a published version of an implementation guide and its dependencies, with the expansions performed using specific versions for all the code system and value set dependencies used by those value sets.

The application supports two primary use cases:

1. Defining _value set packages_ as an implementation guide editor, typically on a periodic basis, to specify what versions of code systems to use for expansions of value sets in the implementation guide.
2. Downloading _value set packages_ as an implementer to obtain complete expansions of value sets in the implementation guide using the specified code system versions for those expansions.

### Implementer User Guide

The _implementer_ user is anyone that needs to access complete expansions for the value sets used in a published implementation guide. This may be application developers, systems integrators, business analysts, or clinicians.

#### Viewing Available Value Set Packages for an Implementation Guide

The Browse Value Set Packages page allows users to view the available value set packages:

<div>
<img src="BrowseValueSetPackages.png" alt="Browse value set packages" width="800"/>
</div>

The page includes a Filter by IG Canonical that allows the set of packages to be filtered to those available for a specific implementation guide. This filter can be set to the canonical URL of the implementation guide resource, optionally including the version. For example, to list the available value set packages for version 6.1.0 of the US Core implementation guide, set the Filter to:

```
http://hl7.org/fhir/us/core/ImplementationGuide/hl7.fhir.us.core|6.1.0
```

In addition, the filter can be set via the url with the `ig-url` parameter:

```
https://cloud.alphora.com/sandbox/vsm/programs?resourceType=vsp&ig-url=&ig-url=http%3A%2F%2Fhl7.org%2Ffhir%2Fus%2Fqicore%2FImplementationGuide%2Fhl7.fhir.us.qicore%7C7.0.1
```

Once the specific value set package has been identified, click on the ID of the value set package in the list to open the Value Set Package View.

#### Retrieving a Value Set Package for an Implementation Guide

To retrieve the Value Set Package, click on the `Export` button in the Value Set Package View:

<div>
<img src="ExportOptions.png" alt="Export options" width="800"/>
</div>

* JSON: The value set package will be downloaded as a FHIR Bundle resource in JSON format
* XML: The value set package will be downloaded as a FHIR Bundle resource in XML format
* CSV: The value set package will be downloaded as a CSV file

#### Comparing Value Set Package Versions

To compare value set package versions, click the `Compare Versions` button:

<div>
<img src="CompareValueSetVersions.png" alt="Compare value set versions" width="800"/>
</div>

Then choose another Value Set Package to compare. This feature allows users to compare differences between the content of two value set packages, displaying differences in:

* Metadata at the package level
* Value sets that are in one package and not the other
* Value sets with differing expansions between the packages

#### Setting Terminology Server Credentials

The Value Set Packages application accesses terminology servers using credentials for each user. To configure the credentials for your user account, go to the settings page, select the terminology endpoint you want to configure, and click `Edit`. Enter the user name and password you use to access the terminology server and click `Save`.

<div>
<img src="TerminologyEndpointSettings.png" alt="Terminology endpoint settings" width="800"/>
</div>

> The Value Set Package Manager only supports Basic Authentication for connections to the terminology server at this time.

### Implementation Guide Editor (Publisher) Guide

The _publisher_ user can create value set packages for download. This user is typically, though not always, a FHIR Implementation Guide editor.

#### Creating a Value Set Package for an Implementation Guide

On the Browse value set packages page, click the `Create Value Set Package` button:

<div>
<img src="CreateValueSetPackage.png" alt="Create value set package" width="800"/>
</div>

If the Canonical IG was set in the browse, it will be used to default the Canonical IG for the package being created.

> The Canonical IG for the value set package must be version-specific (i.e. it must include the pipe and version) to ensure that the value set package is for a specific version of a published implementation guide.

> The Package ID is typically the last part of the canonical URL, but it can also be found in the footer of pages in the published implementation guide.

Once the Canonical and Package ID for the IG are set, click the `Fetch Dependencies from IG` button to start the process of identifying all the value sets and code systems used in the implementation guide and its dependencies. This process can take some time, so the application will allow you to close the edit, preserving current state until the process completes. A notification will appear in the upper right portion of the screen when the dependency process completes.

Other information for the value set package can be set on this page as well:

* Package Name: A Computer-friendly name for the package definition (i.e. no spaces).
* Package Title: A User-friendly title for the package definition
* Package Version: A version for the package definition

> Note that because the package definition is for a specific version of a published implementation guide, that version should be clearly communicated as part of the identity. For example, a September 2025 Value Set Package for US Core 6.1.0 might look like this:

* Name: USCore610VSP
* Title: US Core 6.1.0 Value Set Package
* Version: 2025-09

> For simplicity, and to avoid confusion with the version of the implementation guide the value set package is for, a simple date-based version is recommended for versioning value set packages.

#### Managing the Manifest Parameters

The _manifest_ for a Value Set Package Definition specifies the versions of code system (and potentially value sets) to be used when performing expansions for value sets in the implementation guide.

Initially, the Value Set Package will have manifest parameters for all the code systems and value sets used in the implementation guide and its dependencies. If the version of the code system or value set could be determined from the package, that version will be specified in the manifest parameters.

##### Choosing a Code System Version

Typically, the _external_ (i.e. not HL7-maintained) code systems such as SNOMED, LOINC, an RxNORM, will not have versions specified as part of the published implementation guide, and these are the ones that will need to be _pinned_ by the value set package definition:

<div>
<img src="ChooseCodeSystemVersion.png" alt="Choosing a code system version" width="800"/>
</div>

On the right is a listing of the code systems in the manifest. This is any code system used in any value set in the implementation guide, or any of its dependencies, displayed with the currently specified version, or an Unresolved indicator if no version is set.

On the left is a drop down for the code systems available from the terminology server. Use that drop down to select the code system (SNOMED, for example), and then choose the version of SNOMED to be used. The manifest on the right will be updated with the selected version of the code system.

##### Choosing a Value Set Version

Usually, the version of a value set used is determined by the package dependencies for the implementation guide. In some cases, however, the version of a value set is not specified, and so needs to be set in the same way that code system versions are.

In this case, there are two options:

1. Allow the Release process to determine the value set version
2. Specify the value set version directly as part of the manifest

For the first option, see the Release process documentation.

For the second option, select the Value Sets tab in the Manifest edit:

<div>
<img src="ChooseValueSetVersion.png" alt="Choosing a value set version" width="800"/>
</div>

On the right is a listing of the value sets in the manifest. This is any value set defined in or used by the implementation guide, or any of its dependencies, displayed with the currently specified version, or an Unresolved indicator if no version is set.

On the left is a drop down for the value sets available from the terminology server. Use that drop down to select the value set, and then choose the version of the value to be used. The manifest on the right will be updated with the selected version of the value set.

#### Releasing a Draft Value Set Package

Once the manifest parameters have been set, the value set package can be released. In the Value Set Package view, click the `Release` button to start the release process.

> Prior to releasing, you can review the contents of the package using the `Export` button, as well as compare the contents of the package to other versions using the `Compare Versions` button.

The release process:

1. Identifies the latest available version for any dependency that does not have a manifest entry and records that in the manifest
2. Marks the status of the Value Set Package as `active`

> Once a value set package is released, it can no longer be edited. Changes must be made by creating a new version of the value set package.

#### Withdrawing a Draft Value Set Package

Prior to releasing, a draft value set package can be discarded using the `Withdraw` button.

#### Retiring a Released Value Set Package

Once a Value Set Package is no longer required, it can be retired using the `Retire` button. This process updates the status of the value set package definition to `retired`, indicating that it should no longer be used.

### Administrator User Guide

The _administrator_ user has access to all the functionality available in the Value Set Package manager.

#### User Roles

The Value Set Package manager uses KeyCloak for user administration. The following roles are defined to control access to the available features for the application:

|Action |Implementer |Reviewer |Editor |Publisher |Administrator |
|----|----|----|----|----|----|
|Log in | ✅ | ✅ | ✅ | ✅ | ✅ |
|View specifications | ✅ | ✅ | ✅ | ✅ | ✅ |
|Approve a specification | | ✅ | ✅ | ✅ | ✅ |
|Clone (create draft) | | | ✅ | ✅ | ✅ |
|Edit a draft | | | ✅ | ✅ | ✅ |
|Withdraw a draft | | | ✅ | ✅ | ✅ |
|Retire an active specification | | | | ✅ | ✅ |
|Delete a retired specification | | | | ✅ | ✅ |
|Release a draft | | | | ✅ | ✅ |
|Manage own credentials | ✅ | ✅ | ✅ | ✅ | ✅ |
|Manage endpoint configuration | | | | | ✅ |

#### Terminology Endpoints

At this time, only administrators can configure the terminology endpoints available for use in the value set package manager:

<div>
<img src="OnboardingDetails.png" alt="Onboarding details" width="800"/>
</div>

The application can be configured with any number of endpoints, but requires at least one. If no endpoints are configured, the application will indicate this:

<div>
<img src="TerminologySettings-NoEndpointsDefinedError.png" alt="Browse value set packages" width="800"/>
</div>

Each endpoint can have an associated _route_ that is used to determine which endpoint should be used to support a given value set. The _route_ is a portion of the canonical identifier for the value set. 

For example, VSAC value sets all have a URL that starts with `http://cts.nlm.nih.gov/fhir`, so a VSAC endpoint might be configured like this:

* `route`: `http://cts.nlm.nih.gov/fhir`
* `endpoint`: `https://cts.nlm.nih.gov/fhir`

This instructs the application to use the VSAC endpoint to process value sets whose identifier begins with the `route`.

To ensure that the application always has at least one endpoint that can be used to process any value set, the configuration should always include an endpoint that has no route specified, the _catch-all_ endpoint. If no catch all endpoing it configured, application will indicate this:

<div>
<img src="TerminologySettings-NoCatchAll.png" alt="No catch all" width="800"/>
</div>

When adding a terminology endpoint, connectivity to the endpoint is verified. Endpoint status is displayed in the settings page:

<div>
<img src="TerminologySettings-EndpointStatus.png" alt="Terminology endpoint status" width="800"/>
</div>

As part of configuring an endpoint, specify the authentication to be used:

<div>
<img src="EditEndpoint-NoAuthentication.png" alt="Endpoint authentication options" width="800"/>
</div>

When authentication is configured, each user must provide their own credentials to be used to connect to the terminology endpoint.

### Deployment

For complete local setup instructions, refer to the [VSP Setup](https://github.com/DBCG/aphl-vsm/blob/main/vsp/docs/setup.md) documentation in the Value Set Manager repository.

Although we do not currently have exhaustive recommendations or metrics for usage, for our testing environments, we have been using:

- CPU: 1 vCPU (1024 units)
- Memory: 8 GB (8192 MB)
- Disk: 20 GB

