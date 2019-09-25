---
layout: page
permalink: /projects
title: Projects
---

I have a bad habit of starting and abandoning projects, so most of what is here are small repos or plugins that I worked on over a weekend.
 
 - [`terraform-provider-kong`](https://github.com/alexashley/terraform-provider-kong): This is a [Terraform](https://www.terraform.io/) provider for the API gateway [Kong](https://konghq.com). 
 I implemented service, route, and plugin resources; in addition, I created resources for a few individual plugins in order to provide fine-grain validation. 
 I started it as a hobby project so that I could keep my Go skills up to date; a few months later Kong announced its own declarative configuration format (completely distinct from HCL). 
 Since the integration was baked into Kong, there was no reason to continue tinkering with the provider. 
 - [`keycloak-password-policy-have-i-been-pwned`](https://github.com/alexashley/keycloak-password-policy-have-i-been-pwned): This was a weekend project to integrate [Have I Been Pwned](https://haveibeenpwned.com/) with [Keycloak](https://www.keycloak.org/). 
 I also used it as an opportunity to try out the Kotlin dsl for Gradle. It works by leveraging the internal password policy [SPI](https://en.wikipedia.org/wiki/Service_provider_interface) and throwing an error if the password is found in the pwned password list (or if it is found, if the number of times it appears exceeds a configurable threshold).
 - [`kong-plugin-path-prefix`](https://github.com/alexashley/kong-plugin-path-prefix): This is a tiny [Kong](https://konghq.com) plugin that I wrote to play around with the new (at the time)  plugin development kit. It allows for easier path-based routing by having services declare a prefix that's shared between all routes and that should be stripped before the request goes upstream. 
 By default, Kong will either strip none of the matching prefix or the entire prefix, which makes a shared route prefix a little difficult to use.
 - [`insomnia-plugin-openid-connect`](https://github.com/alexashley/insomnia-plugin-openid-connect): A small plugin for the [Insomnia](https://insomnia.rest/) API client. Insomnia has built-in support for OAuth 2, but not for OpenId Connect. 
 Of course, it's possible to use OpenId Connect by simply adding `openid` to the list of requested scopes, but you lose out on other OpenId Connect benefits like discovery and id token validations. 
 The plugin leverages an Open Id Connect certified client library and pulls config from the environment, so that it doesn't need to be setup on each endpoint. 
 - [`lua-prelude`](https://github.com/alexashley/lua-prelude): Every now and again I use Lua, mainly for Kong, and it's nice to have some familiar JavaScript-like functions for working with tables. So I wrote a small prelude that could be loaded into the Lua REPL.
 - [`MockAttributes`](https://github.com/alexashley/MockAttributes): I wrote this after switching jobs and stacks. My previous employer used Spring with field dependency injection and wrote unit tests using Mockito, which can automatically inject mocks into the system-under-test. 
 At my new employer, I was writing C# and doing constructor injection. I had yet to discover [AutoFixture](https://github.com/AutoFixture/AutoFixture) and manually setting up unit tests was becoming quite the pain. 
 So I wrote this to restore the familiar Mockito attributes that allowed for much simpler setup. It was an interesting project to work on, but I never figured out a clean way to suppress compiler warnings about possible uninitialized fields. 
 And soon after I stumbled upon the great AutoFixture + AutoMoq combo that I now use when I write C# unit tests. 
 - [`enigma`](https://github.com/alexashley/enigma): This was a small project I wrote while getting familiar with Go. It only supports a single machine type, but it was a really fun learning experience. 