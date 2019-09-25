---
layout: page
permalink: /oss
title: Open Source
---

I use a lot of open source software and I enjoy being able to contribute back when I can (even if it's just in a very small way, which most of these are).

## Features

- [newrelic/node-newrelic#277](https://github.com/newrelic/node-newrelic/pull/277) (closed): At work, we were using New Relic for performance and error monitoring, but quickly found that the Node.js agent didn't include instrumentation for any MSSQL packages. 
Unlike JVM-based languages, where database drivers typically conform to [JDBC](https://en.wikipedia.org/wiki/Java_Database_Connectivity), there's no such uniform API for Node.js drivers. This means that the New Relic Node.js agent was instrumenting popular database packages individually.
The PR adds base support for [tedious](https://github.com/tediousjs/tedious), which had been attempted in the past but stalled due to lack of integration tests or contributors losing interest. I spent the bulk of my time on the PR writing integration tests and ensuring that those tests were able to run in CI.
Ultimately, the PR was rejected, due to upcoming architectural changes to the agent, where individual instrumentations would be split into their own packages.
A modified version of that PR is currently running in some codebases at my employer, and giving a level of insight into SQL queries that's nearly equivalent to New Relic's JDBC instrumentation.
- [mrparkers/terraform-provider-keycloak#16](https://github.com/mrparkers/terraform-provider-keycloak/pull/16) (merged): This PR added support for user attribute mappers for both clients and client scopes. 
One of Keycloak's uses for mappers is to add claims to JSON web tokens (JWTs); in this case the mapper grabs values from the authenticated user model and adds them to the JWT.
Mappers can be associated to a single client or part of a client scope that clients can request. The PR extends the Terraform provider with a new resource that supports associating mappers to either a client or client scope.
- [manovotny/eslint-config-get-off-my-lawn](https://github.com/manovotny/eslint-config-get-off-my-lawn/pull/45) (merged): We use [ESlint](https://eslint.org/) quite heavily at work and one of my colleagues maintains the list that we use as an open source project.
For the PR, I added a few rules around `async` functions.  

## Documentation

- [Kong/docs.konghq.com#923](https://github.com/Kong/docs.konghq.com/pull/923) (merged): Retroactively added release dates to the Kong Enterprise changelog.
- [Kong/docs.konghq.com#888](https://github.com/Kong/docs.konghq.com/pull/888) (merged): Fixed a small mistake on one of the plugin options.  
- [posquit0/awesome-kong#1](https://github.com/posquit0/awesome-kong/pull/1) (merged): Added a link to the Kong community call.
- [AlloyTools/alloytools.github.io#16](https://github.com/AlloyTools/alloytools.github.io/pull/16) (merged): Fixed a broken link. 

## Bugs

- [mrparkers/terraform-provider-keycloak#114](https://github.com/mrparkers/terraform-provider-keycloak/pull/114) (merged): The Keycloak Terraform provider repo includes a Keycloak API client, which I was trying to use in an acceptance test. 
The client supports authenticating through either the client credentials flow or the resource owner credentials (password) flow; in my case, I was using the password flow with a confidential client, so I made a change to initialize a struct with the client secret, regardless of flow.
- [Codeception/CodeceptJS](https://github.com/Codeception/CodeceptJS/pull/789) (merged): While writing some acceptance tests using CodeceptJS, I noticed that the default headers were being mutated between scenarios and submitted a PR.
- [exercism/javascript](https://github.com/exercism/javascript/pull/346) (merged): I was playing around with [Exercism](https://exercism.io/) and noticed that a test for one of the exercises would pass when it shouldn't. ]
After fixing that, I found a small problem with the example implementation, so I tweaked that as well in the PR.
