# Architecture
ImgurBar build with [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) approach using [SOLID](https://en.wikipedia.org/wiki/SOLID) principles.

## Core
The Core module contains all platform-agnostic protocols and data structures. It does not contain any business logic.

## AppDelegate

The AppDelegate is a composition root of this project. It creates and combines all the objects into a working solution.

- 🟢 Core
- 🔵 API (Networking)
- 🟠 Application (platform-specific logic)

![ImgurBar Architecture](https://user-images.githubusercontent.com/939390/144887665-75ad26b2-4c65-463c-b87d-a0b384ead8cd.png)
