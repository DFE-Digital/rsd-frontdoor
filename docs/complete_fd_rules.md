## Description
The following rules are applied for the complete application.

The source application is [ruby complete](https://github.com/DFE-Digital/dfe-complete-conversions-transfers-and-changes).

Traffic is redirected to the [dotnet application](https://github.com/DFE-Digital/complete-conversions-transfers-changes) for the routes specified.

## Key

✅ - included. Hitting this route in ruby app will redirect through front door to dotnet for this environment  
❌ - not included. This page is routed fully by ruby and does not come through the front door  
⚠️ - feature flagged. Hitting this route in ruby with the session cookie `"dotnet-bypass"` (any value) will redirect through front door to dotnet. Otherwise, the route will be handled by ruby  
❌ → ✅ - represents a rule change in the most recent update  
🆕 - route added. There are new rules in place for this route as of this release
## Operators

Current "operators" in use include:
 - Begins With - any request route that begins with the specified route will be have the front door rule applied. `projects/*` matches: `projects/foo`, `projects/bar`  
 - Equal - the route must be an exact match. `projects/foo/bar` matches only: `projects/foo/bar` 
 - RegEx - the route will have to match a RegEx pattern


See a more definitive list of operators [here](https://learn.microsoft.com/en-us/azure/frontdoor/rules-match-conditions?tabs=portal&pivots=front-door-standard-premium#operator-list)


**NB**: The table only includes routes that have forwarding enabled for any environment. It is not an exhaustive list of routes that are available on either app.

## Routes  

| Route | Operator | Dev | Test | Prod |  
| - | - | - | - | - |
| /projects/team/* | Begins With | ✅ | ✅ | ⚠️ → ✅ |
| /projects/yours/* | Begins With | ✅ | ✅ | ⚠️ → ✅ |
| /projects/all/handover/* | Begins With | ✅ | ⚠️ → ✅ | ⚠️ → ✅ |
| /projects/all/by-month/* | Begins With | ✅ | ✅ | ✅ |
| /projects/all/completed/* | Begins With | ✅ | ✅ | ✅ |
| /projects/all/in-progress/* | Begins With | ✅ | ✅ | ✅ |
| /projects/all/local-authorities/* | Begins With | ✅ | ✅ | ✅ |
| /projects/all/regions/* | Begins With | ✅ | ✅ | ✅ |
| /projects/all/trusts/* | Begins With | ✅ | ✅ | ✅  |
| /projects/all/users/* | Begins With | ✅ | ✅ | ✅ |
| /projects/all/statistics/* | Begins With | ✅ | ✅ | ✅ |
| /projects/all/export | Equal | ✅ | ✅ | ✅ |
| /projects/all/reports | Equal | ✅ | ✅ | ✅ |
| /groups | Begins With | ✅ | ✅ | ✅ |
| /projects/service-support/with-academy-urn/* | Begins With | ✅ | ✅ | ✅ |
| /projects/service-support/without-academy-urn/* | Begins With | ✅ |  ✅ | ✅ |
| /service-support/local-authorities/* | Begins With | ✅ | ✅ | ✅ |
| /projects/*/academy-urn | RegEx | ✅ | ✅ | ✅ |
| /search | RegEx | ✅ | ✅ | ✅ |
| /cookies (GET) | Begins With | ✅ | ✅ | ✅ |
| /cookies (POST) | Begins With | ✅ | ✅ | ✅ |
| /accessibility | Begins With | ✅ | ✅ | ✅ |
| /privacy | Begins With | ✅ | ✅ | ✅ |
| /access-denied | Begins With | ✅ | ✅ | ✅ |


## Version history:

**7 - 2925-08-22** - Promote team projects, your projects and project handover to production  
**6 - 2025-08-20**
- add privacy notice, groups, service support (LAs and URNs) in production
- add `/projects/{project_id}/academy-urn` to all environments using a regex match. GET and POST requests expected for creating urns. RegEx: `projects/.*/academy-urn`
- for tighter checks, we could consider RegEx: `^\/projects\/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\/academy-urn$`

**5 - 2025-08-15** - add privacy notice and groups routes, and add feature flag to service support (LAs and URNs) in production  
**4 - 2025-08-07** - add access-denied route, which exists only on .NET. Otherwise, access denied pages present as "Page not found"  
**3 - 2025-08-05**
- release additional listing pages to production, excluding "Your projects" and "Team projects"
- release handover to dev and to test/prod with feature flag  

**2 - 2025-07-25** - change export and reports to exact match as "All projects by month" has a CSV download that uses `/projects/all/exports/*`  
**1 - 2025-07-25** - initial documentation. Capture FD rules as they are  
