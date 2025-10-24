## Surfacing Key Elements During $package

Ensure that Value Set Package specification $package results include "all value sets and dependencies, recursively", meaning, the resulting package will include expansions for all and only the value sets bound by elements of profiles in the implementation guide as well as those inherited from base profiles and/or resources.

In more detail, this means the package would include value sets that are referenced by key elements in profiles defined in the implementation guide, resulting in the inclusion of inherited key elements. Recursively here means that this inheritance applies to the derived profiles all the way back to the resource on which the profile is defined.

> BR: We should keep the "key elements" decision separate from the "recursively" decision

> BR: I think there are 3 options we need to consider for recursion too:
> 1. Not recursive (i.e. only consider artifacts that are "in" the artifact being packaged) (this is roughly packageOnly = true)
> 2. Recursive, but excluding core (consider artifacts that are in dependencies, but not if that dependency is the core spec)
> 3. Fully recursive (this is roughly packageOnly = false)
>
> The dependency trace should be complete, regardless of how the packaging is performed

### CRMI $package Context

- $package already takes include, which can include terminology, profiles, examples, etc.  ￼
- $package also takes manifest, which is a canonical reference to a CRMI Manifest Library. The manifest is an asset-collection Library that lists components and dependencies (via relatedArtifact slices) and also carries pinned terminology versions and expansion parameters.  ￼
- The output bundle always starts with an "outcome manifest" (basically: what happened, warnings, etc.). 

### Potential Approaches

There are approaches that do not require changes to the CRMI specification and approaches that do require changes.

#### No CRMI Specification Change Approaches

1. Server-defined semantics of include=terminology
   - CRMI $package already has include, and terminology is one allowed code meaning "include terminology resources (CodeSystem, ValueSet, etc.)".
   - This could be interpreted as: 
     - When include contains terminology, we don't just brute-force every ValueSet referenced anywhere in the profile.
     - Instead, we run the Key Elements procedure and include only those ValueSets.
   - The main downside of this approach is that the CRMI spec today does not normatively say "terminology == Key Elements algorithm." Another server might infer the terminology include parameter differently. So portability is fuzzy.
2. Use includeUri/excludeUri
   - include=profiles, include=conformance, etc. for the "normal" stuff.
   - Pass each required ValueSet as includeUri={canonical}|{version}.
   - Do not ask for include=terminology at all (or ask for it and then use excludeUri to prune).
   - The main downside of this approach is the caller (or a helper service in front of $package) needs to run that Key Elements traversal before calling $package. So the logic still exists, but it runs client-side instead of inside the package operation.
  
> BR: I don't think we should try to fit this into the existing because as you point out, there's too much room for discrepancy in implementation, I think we need new parameters that are explicit about the behavior we expect.

#### CRMI Specification Change Approaches

1. New include code (terminology-key-elements)
   - Minimal change: just extend include.
   - Server computes Key Elements and filters terminology.
2. New parameter terminologyScope (all | key-elements | none)
   - Clear separation of "what kinds of resources to include" vs "how aggressively to filter terminology."
   - Server still computes Key Elements.
3. Manifest-precomputed key terminology slice
   - Extend CRMI Manifest Library with a new relatedArtifact slice like required-terminology.
   - $package uses that slice when include=terminology.
   - Very little runtime logic.
4. Manifest dependency roles and new dependencyRole filter param
   - Manifest classifies each dependency (including ValueSets) with a role (key-element-terminology, etc.).
   - New $package parameter dependencyRole aligns with manifest role and returns only those dependencies.
   - Scales beyond just this use case.
5. Annotate, don't filter
   - $package still returns full terminology (include=terminology),
   - but the outcome manifest / manifest library in the Bundle also flags which terminology is key-element-required.
   - Client can trim locally.
6. bindingProfile parameter
   - New $package parameter bindingProfile (0..* canonical(StructureDefinition)).
   - Server includes only terminology needed for the Key Elements of those specific profiles, recursively through their baseDefinition.
   - Useful when the caller only wants a subset of an IG.
  
> BR: I don't think we should mix the key element tracing with terminology. That's what the feature is focused on for value set packages, but the idea is more general than that, and I think we'll get a more flexible implementation by keeping the notions orthogonal. I like the dependencyRole idea, and the $release operation could flag, as part of its dependency walk, the role that the dependency is in. We could extend that to include the notions of "test", and "example" and that would give us a way to capture those types of dependencies (and then give meaning to the "test" and "example" include codes as well). And in fact, by allowing the "role types" as "include codes" we could without introducing a new parameter, use that to do the filtering. So...
>
> crmi-dependencyRole - valueCode - bound required to { default, key, example, test }
>
> If a dependency has no dependencyRole, it is assumed to be a "default" dependency
> If no dependency role include code is specified, all dependencies are assumed to be included
> A key dependency is one encountered while walking a dependency from a key element
> Dependency roles are imposed recursively (i.e. a CodeSystem referenced from a key ValueSet is a key CodeSystem)
> Dependency roles are cumulative (i.e. a CodeSystem dependency referenced from both a key ValueSet and an example ValueSet is both a key and an example dependency)

