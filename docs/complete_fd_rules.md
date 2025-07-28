## Description
The following rules are applied for the complete application.

The source application is [ruby complete](https://github.com/DFE-Digital/dfe-complete-conversions-transfers-and-changes).

Traffic is redirected to the [dotnet application](https://github.com/DFE-Digital/complete-conversions-transfers-changes) for the routes specified.

## Key

✅ - included. Hitting this route in ruby app will redirect through front door to dotnet for this environment  
❌ - not included. This page is routed fully by ruby and does not come through the front door  
⚠️ - feature flagged. Hitting this route in ruby with the session cookie `"dotnet-bypass"` (any value) will redirect through front door to dotnet. Otherwise, the route will be handled by ruby  
❌ → ✅ - represents a rule change in the most recent update

## Operators

Current "operators" in use include:
 - Begins With - any request route that begins with the specified route will be have the front door rule applied. `projects/*` matches: `projects/foo`, `projects/bar`  
 - Equal - the route must be an exact match. `projects/foo/bar` matches only: `projects/foo/bar` 
 - RegEx - the route will have to match a RegEx pattern

**NB**: The table only includes routes that have forwarding enabled for any environment. It is not an exhaustive list of routes that are available on either app.

| Route | Operator | Dev | Test | Prod |  
| - | - | - | - | - |
| /projects/team/* | Begins With | ✅ | ✅ | ⚠️ |
| /projects/yours/* | Begins With | ✅ | ✅ | ⚠️ |
| /projects/all/by-month/* | Begins With | ✅ | ✅ | ⚠️ |
| /projects/all/completed/* | Begins With | ✅ | ✅ | ⚠️ |
| /projects/all/in-progress/* | Begins With | ✅ | ✅ | ✅ |
| /projects/all/local-authorities/* | Begins With | ✅ | ✅ | ⚠️ |
| /projects/all/regions/* | Begins With | ✅ | ✅ | ⚠️ |
| /projects/all/trusts/* | Begins With | ✅ | ✅ | ⚠️ |
| /projects/all/users/* | Begins With | ✅ | ✅ | ⚠️ |
| /projects/all/statistics/* | Begins With | ✅ | ✅ | ⚠️ |
| /projects/all/export | Begins With → Equal | ✅ | ✅ | ✅ |
| /projects/all/reports | Begins With → Equal | ✅ | ✅ | ✅ |
| /projects/service-support/with-academy-urn/* | Begins With | ✅ | ⚠️ | ❌ |
| /projects/service-support/without-academy-urn/* | Begins With | ✅ | ⚠️ | ❌ |
| /service-support/local-authorities/* | Begins With | ✅ | ⚠️ | ❌ |
| /search | RegEx | ✅ | ✅ | ✅ |
| /cookies (GET) | Begins With | ✅ | ✅ | ✅ |
| /cookies (POST) | Begins With | ✅ | ✅ | ✅ |
| /accessibility | Begins With | ✅ | ✅ | ✅ |


## Version history:

**1 - 2025-07-25** - initial documentation. Capture FD rules as they are  
**2 - 2025-07-25** - change export and reports to exact match as "All projects by month" has a CSV download that uses `/projects/all/exports/*`  