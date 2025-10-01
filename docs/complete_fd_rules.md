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
 - BeginsWith - any request route that begins with the specified route will be have the front door rule applied. `projects/*` matches: `projects/foo`, `projects/bar`  
 - EndWith - any request route that end with the specified route will be have the front door rule applied. `/tasks/handover` matches: `project/123/tasks/handover`    
 - Equal - the route must be an exact match. `projects/foo/bar` matches only: `projects/foo/bar` 
 - RegEx - the route will have to match a RegEx pattern


See a more definitive list of operators [here](https://learn.microsoft.com/en-us/azure/frontdoor/rules-match-conditions?tabs=portal&pivots=front-door-standard-premium#operator-list)


**NB**: The table only includes routes that have forwarding enabled for any environment. It is not an exhaustive list of routes that are available on either app.

## Ruby fallback

It is possible to ignore all of the rerouting rules in your local browser, which can be very useful for testing and debugging.

By providing the request cookie `dotnet-disable`, all routes will revert to ruby rather than redirecting to .net.

## Task identifiers

We are releasing various tasks through the front door - a list of tasks which will progressively get longer.

For brevity, I've just referenced these tasks as {task_identifiers} in the Routes table (see below).

The full "route" looks something like this: **/projects/\*/tasks/{task_identifiers}** - where {task_identifiers} matches one of the promoted tasks.

At present, these tasks are:
- handover
- stakeholder_kick_off
- proposed_capacity_of_the_academy
- supplemental_funding_agreement
- articles_of_association
- deed_of_variation
- conditions_met
- redact_and_send
- redact_and_send_documents
- receive_grant_payment_certificate
- declaration_of_expenditure_certificate
- deed_of_novation_and_variation

## Routes  

| Route | Operator | Dev | Test | Prod |  
| - | - | - | - | - |
| /projects/*/academy-urn | RegEx | ✅ | ✅ | ✅ |
| /projects/*/internal-contacts/\* | RegEx | ✅ | ⚠️ | ⚠️ |
| /projects/*/tasks | RegEx | ✅ | ⚠️ | ⚠️ |
| /projects/\*/notes/\* | RegEx | ✅ | ⚠️ → ❌ | ⚠️ → ❌  |
| **/projects/\*/date_history/\*** | **Regex** | 🆕✅ | 🆕⚠️ | 🆕⚠️ |
| **/projects/\*/tasks/{task_identifiers}** | **Regex** | 🆕✅ | 🆕⚠️ | 🆕⚠️ |
| /projects/\*/information/\* | RegEx | 🆕✅ | 🆕⚠️ | 🆕⚠️ |
| /projects/{project_type}/\* | RegEx | 🆕✅ | 🆕⚠️ | 🆕⚠️ |
| /projects/team/* | Begins With | ✅ | ✅ | ✅ |
| /projects/yours/* | Begins With | ✅ | ✅ | ✅ |
| /projects/all/handover/* | Begins With | ✅ | ✅ | ✅ |
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
| /search | RegEx | ✅ | ✅ | ✅ |
| /search/user | RegEx | ✅ | ⚠️ | ⚠️ |
| /cookies (GET) | Begins With | ✅ | ✅ | ✅ |
| /cookies (POST) | Begins With | ✅ | ✅ | ✅ |
| /accessibility | Begins With | ✅ | ✅ | ✅ |
| /privacy | Begins With | ✅ | ✅ | ✅ |
| /access-denied | Begins With | ✅ | ✅ | ✅ |


## Version history:

**9 - 2025-10-02**
- remove notes feature flag from test and prod to allow for "clean" testing. Notes will need releasing after all tasks due to TmpData buglets  
- add various tasks routes (10 in total) using an EndsWith pattern  
- add date history and about the project (/information) using the same regex as project notes, internal contacts
- add `/projects/{project_type}/{project_id}*` to all environments using a regex match. RegEx: `^projects/(?:conversions|transfers)/[^/]+(?:/.*)?(?:#.*)?$`

**8 - 2025-08-28**
- add notes, internal contacts and task list to dev, feature flagged in test/prod
- add `/projects/{project_id}/internal-contacts/*` to all environments using a regex match. GET and POST requests expected for creating urns. RegEx: `^projects/.*/internal-contacts.*`
- add `/projects/{project_id}/tasks` to all environments using a regex match. RegEx: `^projects/[^/]+/tasks$`
- add `/projects/{project_id}/notes` to all environments using a regex match. RegEx: `^projects/[^/]+/notes.*` - **Note** This needs testing thoroughly with task notes because there's metadata that impacts flow
- add `/search/user` to all environments using a regex match. RegEx: `^search/user(?:\\?(?:[^\\/#]*))?$`

**7 - 2925-08-22** - Promote team projects, your projects and project handover to production  
**6 - 2025-08-20**
- add privacy notice, groups, service support (LAs and URNs) in production
- add `/projects/{project_id}/academy-urn` to all environments using a regex match. GET and POST requests expected for creating urns. RegEx: `^projects/[^/]+/academy-urn$`
- for tighter checks, we could consider RegEx: `^\/projects\/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\/academy-urn$`

**5 - 2025-08-15** - add privacy notice and groups routes, and add feature flag to service support (LAs and URNs) in production  
**4 - 2025-08-07** - add access-denied route, which exists only on .NET. Otherwise, access denied pages present as "Page not found"  
**3 - 2025-08-05**
- release additional listing pages to production, excluding "Your projects" and "Team projects"
- release handover to dev and to test/prod with feature flag  

**2 - 2025-07-25** - change export and reports to exact match as "All projects by month" has a CSV download that uses `/projects/all/exports/*`  
**1 - 2025-07-25** - initial documentation. Capture FD rules as they are  
