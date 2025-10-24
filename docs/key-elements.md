## Key Element Definition

Determining the key elements of a profile consists of:
- Starting with mustSupport elements, elements changed in the differential, and their ancestors, then
- Recursively adding mandatory children, constrained children, sliced children, modifier elements, etc.

## Key Element Procedure

Using the key element definition, a procedure can be determined to run on a StructureDefinition (SD).

### Step A. Seed Set

Build an initial set of elements like this:
- The root elements of the profile.
- Every element in the profile where:
  - mustSupport = true, OR
  - the element appears in the differential (i.e. the IG said something about it, so it's important for implementers), OR
  - it's an ancestor of any of the above (so if Condition.code is mustSupport, then Condition and Condition.code and any parent path segments like Condition.category's parent Condition are in).  ￼

In code terms: walk the differential, mark each element that appears there, bubble those markings up path-wise (e.g. split Condition.category.coding marking Condition and Condition.category).

### Step B. Expand Downward

For each element in that seed set:
- Pull in any of its children if ANY of these are true:
	- The child has min != 0 (i.e. it's mandatory in this profile/slice).
	- The child's max was constrained from the core default (e.g. narrowed to 1 or made 0..0 or similar), because that changes what data can legally appear.
	- The child participates in an invariant/constraint that governs required presence/absence.
	- The child is a slice (slices impose specific rules on how an element can appear).
	- The child is a modifier element (isModifier = true).  ￼

For any child we just added, recurse B again. That matches "Recurse step (b) for any newly included elements."  ￼

At the end we've got the formal key elements set for that StructureDefinition.

### Step C. Binding Inclusion

Now that we know which elements are "key," we look at those elements' bindings:
- If an included element has binding.valueSet, we take that ValueSet's canonical URL.
- We also carry forward bindings that are still inherited from base (e.g. clinicalStatus on Condition). This matters because the IG might not restate that binding in its differential, but it's still semantically required to populate/interpret the instance.

### Step D. Inheritance Walk

Do that for:
- The IG's profile.
- Its baseDefinition profile.
- Keep walking baseDefinition until you get to the core resource definition.

For each level, run Steps A–C and union the ValueSets.
