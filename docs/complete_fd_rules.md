## Description
The following rules are applied for the complete application.

The source application is [ruby complete](https://github.com/DFE-Digital/dfe-complete-conversions-transfers-and-changes).

Traffic is redirected to the [dotnet application](https://github.com/DFE-Digital/complete-conversions-transfers-changes) for the routes specified.

## Key

✅ - included. Hitting this route in ruby app will redirect through front door to dotnet for this environment  
❌ - not included. This page is routed fully by ruby and does not come through the front door  
⚠️ - feature flagged. Hitting this route in ruby with the session cookie `"dotnet-bypass"` (any value) will redirect through front door to dotnet. Otherwise, the route will be handled by ruby  


**NB**: The table only includes routes that have forwarding enabled for any environment. It is not an exhaustive list of routes that are available on either app.

| Route | Dev | Test | Prod |  
| - | - | - | - |
| /projects/team/* | ✅ | ✅ | ⚠️ |
| /projects/yours/* | ✅ | ✅ | ⚠️ |
| /projects/all/by-month/* | ✅ | ✅ | ⚠️ |
| /projects/all/completed/* | ✅ | ✅ | ⚠️ |
| /projects/all/in-progress/* | ✅ | ✅ | ✅ |
| /projects/all/local-authorities/* | ✅ | ✅ | ⚠️ |
| /projects/all/regions/* | ✅ | ✅ | ⚠️ |
| /projects/all/trusts/* | ✅ | ✅ | ⚠️ |
| /projects/all/users/* | ✅ | ✅ | ⚠️ |
| /projects/all/statistics/* | ✅ | ✅ | ⚠️ |
| /projects/all/exports/* | ✅ | ✅ | ✅ |
| /projects/all/reports/* | ✅ | ✅ | ✅ |
| /projects/service-support/with-academy-urn/* | ✅ | ⚠️ | ❌ |
| /projects/service-support/without-academy-urn/* | ✅ | ⚠️ | ❌ |
| /service-support/local-authorities/* | ✅ | ⚠️ | ❌ |
| /search | ✅ | ✅ | ✅ |
| /cookies (GET) | ✅ | ✅ | ✅ |
| /cookies (POST) | ✅ | ✅ | ✅ |
| /accessibility | ✅ | ✅ | ✅ |





