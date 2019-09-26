---
layout: post	
title:  Keycloak Node.js Adapter DoS
date:   2019-09-26
permalink: /2019/09/26/nodejs-keycloak-dos
tags: keycloak nodejs security
---

This post is about an issue I discovered in the official [Keycloak Node.js adapter](https://github.com/keycloak/keycloak-nodejs-connect), which is maintained by Red Hat. 
It was assigned a low-grade [CVE](https://nvd.nist.gov/vuln/detail/CVE-2019-10157) and has since been fixed by the maintainers. 

## Background

[Keycloak](https://www.keycloak.org/) is an open source identity and access management server. 
It implements [OpenID Connect](https://en.wikipedia.org/wiki/OpenID_Connect) and [SAML](https://en.wikipedia.org/wiki/Security_Assertion_Markup_Language); in addition, it extends those protocols with useful features and offers its own authorization and policy system.

Keycloak supports multiple realms, allowing for different groups of users and applications in each realm. 
Often it's the case that applications in a realm want to give the illusion of a single shared session per user; such that when a user logs out through one application, they're logged out of all applications in that realm. There are a couple of strategies to solve this problem, and they can even be used in conjunction. 

On the front-end, clients can use the OpenID provider's `check_session_iframe` and periodically poll for session state. If the session state changes, they can try to re-authenticate silently or display a message to the user. 
This has the advantage of providing a good user experience if the application is currently open, but has the downsides that the user must have working JavaScript and the client most notify the server to end its session.
Since clients may have a poor network connection or may even be malicious, it's best to pair this with a server side mechanism. 
Unfortunately, while OpenID Connect does support a backchannel [logout](https://openid.net/specs/openid-connect-backchannel-1_0.html), the specification has remained a draft and isn't implemented by Keycloak.
However, Keycloak does have its own mechanism, which is fairly similar to the draft spec (although it was implemented sometime prior).
In order to receive logout notifications with Keycloak, clients must configure an admin URL in the console and, optionally, use the client adapter libraries that handle registering admin endpoints for logout and other features. 

![client admin URL](/assets/admin-url.png)

In addition, clients must send an extra field during the code exchange, `client_session_state`, which represents an identifier for the client's own internal session for that user. 
Then, when the user logs out through another application, Keycloak will iterate through clients in the realm and send an HTTP POST request to `${clientAdminUrl}/k_logout` with a signed JWT to any client that has a session for the user. 
The `adapterSessionIds` claim will contain the `client_session_state`s that should be ended.   

```json
{
  "id": "7a793249-7ac3-4d49-8e45-35299eed7e8e-1569530018915",
  "expiration": 1569530048,
  "resource": "nodejs-connect",
  "action": "LOGOUT",
  "adapterSessionIds": [
    "01kMTLenWUextmhG1n61qn7hNd_F1hgR"
  ],
  "notBefore": 0,
  "keycloakSessionIds": [
    "9184528f-eccb-4936-970a-00bc0b892c94"
  ]
}
```

The other claim of interest here is `notBefore`. In case of a breach or other security issue, Keycloak allows administrators to revoke all tokens issued before a certain date. 
This isn't an OpenID Connect feature (although OIDC/OAuth 2 does have the concept of token revocation), so the behavior is baked into the client adapter libraries, which hold onto the most recent not-before policy that they were given.
To update the client's policy, Keycloak uses that same admin URL with a new endpoint, `/k_push_not_before`.   

![admin revocation with not before](/assets/nbf.png)

## Discovery

Due to the fact that I wasn't using a web framework supported by the Keycloak Node.js adapter, I found myself looking into how Keycloak and the adapters handle backchannel logout. 
Naturally, I started with the Node.js adapter, and found where the admin logout handler lives:

```js
function adminLogout (request, response, keycloak) {
  let data = '';

  request.on('data', d => {
    data += d.toString();
  });

  request.on('end', function () {
    let payload;
    let parts = data.split('.');
    try {
      payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
    } catch (e) {
      response.status(400).end();
      return;
    }
    if (payload.action === 'LOGOUT') {
      let sessionIDs = payload.adapterSessionIds;
      if (!sessionIDs) {
        keycloak.grantManager.notBefore = payload.notBefore;
        response.send('ok');
        return;
      }
      if (sessionIDs && sessionIDs.length > 0) {
        let seen = 0;
        sessionIDs.forEach(id => {
          keycloak.unstoreGrant(id);
          ++seen;
          if (seen === sessionIDs.length) {
            response.send('ok');
          }
        });
      } else {
        response.send('ok');
      }
    }
  });
}
```

When it receives an admin logout request, the handler parses the JWT from the payload and attempts to decode it. If that fails, the adapter will return a 400. 
Otherwise, the handler either iterates through the given sessions and ends them, or it updates its internal not-before policy. 
To be honest, I'm not sure why it pulls the `notBefore` policy if there are no session ids, given that there's a dedicated endpoint for that. 
I suspect it might be for ending all sessions for a single client, as opposed to just sessions for a user. 

Surprisingly, there's no authentication here. The logout token is signed by a realm key, but that's never verified. 
The validity of the request hinges entirely on checking the token signature, since Keycloak does not send an `Authorization` header with the request.
Still, it doesn't look all that big of a problem at first -- the adapter expects the client to be using `express-session`, which will generate a random, unique id using Node's `crypto.randomBytes` function. 
So it's unlikely that an attacker could simply guess a number of valid session ids. However, if we omit the `adapterSessionIds` claim, the adapter will instead update its internal `notBefore` timestamp.
Naturally, I was curious what would happen if I were to POST an unsigned JWT with a `notBefore` way in the future -- was there some other check that I didn't see here? 

So I cloned the repo, started up the example project, and sent this curl command:

```bash
    curl http://localhost:3000/k_logout -d "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY3Rpb24iOiJMT0dPVVQiLCJub3RCZWZvcmUiOjE2MDA5OTIwMDB9"
``` 

The unsigned JWT decodes to:

```json
{
  "action": "LOGOUT",
  "notBefore": 1600992000
}
```

which will set the client's internal not-before policy to a year in the future, causing it to reject otherwise valid tokens. 

![example app response](/assets/access-denied.png)

An attacker could use this to indefinitely deny access to applications using the adapter, short of some developer or administrator intervention to reset the not-before policy. 

## Fix

I reported this to Keycloak, following their security issue disclosure instructions. My first reproduction used a small Node.js script, but I realized eventually that it could just be a simple `curl` command.
A few months after reporting, a fix was [released](https://github.com/keycloak/keycloak-nodejs-connect/commit/a971be3cb2ba9a411e51a159a95ac357a22e888b) that updated all admin endpoints with a check of the JWT signature.  
 